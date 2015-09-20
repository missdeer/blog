---
layout: post
title: "树莓派做翻墙网关"
categories: embed
description: 树莓派做翻墙网关
tags: raspberrypi GFW gateway redsocks shadowsocks
---
想做这个东西想了有好些日子了，一方面是懒，执行能力太差，另一方面是在纠结要不要自己写一个程序，昨天经过一天的折腾，终于搞定了，最后我终于没有自己写程序。

在网上搜了很多文章来看，很多都是把树莓派当WIFI AP来用的，但我这里不是。我的树莓派只有1个自带的eth网卡，我把它做成一个网关，让所有的设备在网络设置的网关一项都填树莓派的IP，基本实现其他设备无配置无缝自动翻墙。

其实过程非常简单。

首先，当然是要有能用的代理，无论是http proxy还是socks proxy，甚至只是一个shadowsocks server也行，现有的工具都能适配使用。

然后，用redsocks或ss-redir在树莓派上开端口，一定要监听在0.0.0.0上，我之前就是开在127.0.0.1上，然后纠结了大半天，一直是树莓派自己能翻过去，其他把它当网关的机器翻不出去。redsocks目前我看到有两个不同版本，一个[原版](https://github.com/darkk/redsocks)，从2012年以来就很少更新了，可以将本地tcp流量封装到http connect/http relay/socks协议里，配合iptables等机制实现系统全局代理，另一个是[国人修改版](https://github.com/semigodking/redsocks)，在原版的基础上又增加了一些功能，比如后端协议还支持了shadowsocks（就跟ss-redir一样）和直连，以及auto proxy自动检测是否需要代理，还有自称修正了一些原版中的bug等等。但我昨天试用下来，发现这新增的功能很不稳定，基本经不起日常使用。我最后就直接用了ss-redir，这是[shadowsocks-libev](https://github.com/madeye/shadowsocks-libev/)中的一个工具，功能与redsocks类似，但它只提供了shadowsocks的协议作为后端，不过胜在稳定，又不用多走一次socks5代理，所以估计效率也会好一点。

接着，把树莓派设置流量转发。打开/etc/sysctl.conf，设置net.ipv4.ip_forward=1，让更新实时生效: sysctl -p /etc/sysctl.conf。这样树莓派就已经可以做为网关使用了。还要把流量转发到ss-redir开的端口（我用58100）上去，Linux上用iptables：

```bash
iptables -F
iptables -X
iptables -Z

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -A INPUT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 58100 -m state --state NEW,ESTABLISHED -j ACCEPT

# dnat
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE
iptables -t nat -N SS
# 过滤私有地址，vps地址
iptables -t nat -A SS -d 127.0.0.1 -j RETURN
iptables -t nat -A SS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SS -d 172.16.0.0/21 -j RETURN
iptables -t nat -A SS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SS -d shadowsocks-server-ip -j RETURN

# 过滤中国ip地址，网上搜一下“中国ip段"
iptables -t nat -A SS -d 58.14.0.0/15 -j RETURN
iptables -t nat -A SS -d 58.16.0.0/13 -j RETURN
iptables -t nat -A SS -d 58.24.0.0/15 -j RETURN

# 所有其他的ip，都提交给shadowsocks
iptables -t nat -A SS -p tcp -j REDIRECT --to-port 58100

# 使用SS链，其他设备走PREROUTING链
iptables -t nat -A PREROUTING -p tcp -j SS
# 使用SS链，树莓派自己走OUTPUT链
iptables -t nat -A OUTPUT -p tcp -j SS

```

中间有一段中国IP地址的，有个叫[chnroute](https://github.com/jimmyxu/chnroutes)的项目，简单的做法就只有一条命令：

```
curl http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest | grep 'apnic|CN|ipv4' | awk -F\| '{ printf("iptables -t nat -A SS -d %s/%d -j RETURN\n", $4, 32-log($5)/log(2)) }' > cn_rules.conf
```

，再把文件`cn_rules.conf`的内容执行一下。

最后，把家里所有要翻墙的设备都在网关一项里填成树莓派的IP。比较方便的做法是，在DHCP那里就直接返回树莓派的IP当网关。比较郁闷的是我的Netgear R6300v2貌似没找到怎么在DHCP里设置自定义的网关地址。当然树莓派一定要用静态设置上级路由器的IP为网关。这样所有连入的设备就自动能翻墙了。

上面还有一点没提到的是DNS污染的问题，现在也有很多方案了，我的做法是在树莓派上建了个dnsmasq，上游走OpenDNS的5353端口，国内常用域名有个[列表](https://github.com/felixonmars/dnsmasq-china-list/blob/master/accelerated-domains.china.conf)，走114DNS。