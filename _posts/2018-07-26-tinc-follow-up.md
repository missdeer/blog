---
layout: post
author: missdeer
title: "tinc后续"
categories: network
description: tinc后续
tags: tinc
---

之前用tinc构建了虚拟专网，实现了在不同局域网内的机器通过tinc互相访问，但是遇到一个问题，我想从公司里访问到家里其他没有装tinc的机器，或者从家里其他没有装tinc的机器访问到公司里装了tinc的机器。经过一番简单的设置便可以达到想要的效果。

家里一台HTPC装了tinc，新增IP为`192.168.88.3`，内网IP为`192.168.66.110`，家里所有机器网关都指向软路由，假设IP为`192.168.66.1`，修改相应配置。

修改所有机器上的`/etc/tinc/bignet/hosts/shhtpc`文件，头部增加一行：

```。
Subnet = 192.168.66.0/24
```

刷新tinc的配置，要用`sudo`：

```bash
sudo tincd -n bignet -kHUP
```

设置流量转发，修改`/etc/sysctl.conf`：

```
net.ipv4.ip_forward=1
```

执行以下命令使其生效：

```bash
sudo sysctl -p
```

修改路由器`192.68.66.1`上的静态路由：

```bash
sudo ip route add 192.168.88.0/24 via 192.168.66.110
```

至此，家里所有机器的流量先全部流到路由器，路由器发现目标IP地址是`192.168.88.0/24`范围内的，重路由到HTPC上（`192.168.66.110`）。

修改公司所有机器上的`/etc/tinc/bignet/tinc-up`文件，增加一条静态路由：

```bash
sudo route add -net 192.168.66.0/24 192.168.88.3 255.255.255.0
```

即把`192.168.66.0/24`网段的流量路由到HTPC上。

因为我家里的路由器和HTPC使用的操作系统都是Linux，公司的电脑都是macOS系统，所以增加静态路由使用不同的命令。

至此，公司可以直接访问`192.168.66.0/24`网段内的所有机器。

----

tinc装在Windows上只需要装好tap-Windows驱动，设置好虚拟IP和子网掩码，就不需要手动设置路由，但在上面这种情况下，需要另外加一条静态路由，以管理员身份运行cmd.exe，输入命令：

```
route add 192.168.66.0 mask 255.255.255.0 192.168.88.6 metric 3
```

命令中`192.168.88.6`是本机的tinc虚拟IP，我猜改成HTPC的IP应该也可以，没试过。

----

由于不能控制公司的路由器，所以不能给公司所有主机修改路由设置，如果要从家里访问公司里其他主机，比如访问公司内网的网站，我认为比较简单的方法是修改家中的路由器设置：

1. 开一个SSH隧道到公司任意一台装了tinc也装了OpenSSH server的机器：

   ```
   ssh -D 8089 -f -C -q -N username@192.168.88.4
   ```

   其中`192.168.88.4`就是公司某一台装了tinc也装了OpenSSH server的机器。

2. 装redsocks，并指向SSH隧道开的本地端口：

   ```
   ip = 127.0.0.1;
   port = 8089;
   type = socks5;
   ```

   假设redsocks监听在58096端口上。

3. 修改iptables防火墙设置：

   ```
   -A SS -d 10.0.0.0/8 -p tcp -j REDIRECT --to-ports 58096
   -A SS -d 173.36.0.0/14 -p tcp -j REDIRECT --to-ports 58096
   -A SS -d 172.0.0.0/8 -p tcp -j REDIRECT --to-ports 58096
   -A SS -d 171.68.0.0/14 -p tcp -j REDIRECT --to-ports 58096
   -A SS -d 72.163.0.0/16 -p tcp -j REDIRECT --to-ports 58096
   ```

   把所有公司内网用到的IP段流量都重定向到58096端口。

4. 在公司某一台装了tinc的机器上装一个DNS server，在家里把所有公司内网用到的域名都使用该DNS server进行解析，比如dnsmasq设置为：

   ```
   server=/.cisco.com/192.168.88.4#35353
   server=/.webex.com/192.168.88.4#35353
   server=/.webexconnect.com/192.168.88.4#35353
   server=/.wbx2.com/192.168.88.4#35353
   ```

   其中`192.168.88.4`就是公司某一台装了DNS server的机器，监听在35353端口。

这时，家里所有机器应该都可以访问公司内网的网站，登录收发邮件等等。

我之前并没有使用SSH隧道，而是在公司机器上使用polipo提供http代理，发现它并不能正确代理非http端口的流量请求，而SSH隧道就没这个问题，不知是polipo的限制，还是因为SSH隧道使用socks5协议是会话层协议的缘故。