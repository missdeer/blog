---
layout: post
title: "在家里无缝访问公司网络"
categories: network
description: 没有VPN，在家里无缝访问公司网络
tags: Router BananaPi
---

有时候在家里时想访问公司网络，干点活（真是个好员工），主要就是开开内网的网页，连连内网的IM（Cisco Jabber）。本来这个事情只要有一个VPN就可以搞定了，但是！但是我没有权限申请VPN，于是只好另辟蹊径了。

首先，找到一个用于搭建内网隧道的反向代理工具[frp](https://github.com/fatedier/frp)，通过它在家里开一个服务端，在公司开客户端，于是家里的机器上就有了一个socks5端口，通过该端口就可访问到公司内网的资源了。于是网络拓扑大体如下图所示：

![https://www.umlgen.com/svg/UDfpA2v9B2efpStXvKhEoIzDKKZEpor8pAjKgERbKW22lFoKL8NopBoK_F9YXMY860YufERaFEtVy7HF_xCvkruiRWs7A34qW2Y9HTATcPkOZAmrqpSn6QwgbfSBPdD6VcugYhL5-QKbgKN8MfqIyu1G8I1J8UBfefaljgz_FcKZfeKU8G7EoBgUzYvulg-lmiBiwOR-9pjs0nsCgSSn05b7a9cnWK6PaKAufvidfbgNrBBCv5H352l0GV5yojONBHDnQJ12rl1ypPGNwpOycxC6lnvZ54jsRdusTpz-3Nue6YQqFD-u-rbdDxANmI4EYr5TNJjeCFDoWUC9MG0Q_heQ1fgwu4154t8CuEK2XXk40mqK314Z315Z314_NYw7rBmKO2e40A02n7C0](../../../media/2018-04-27/topo.svg)

我把服务端放在占美x86小主机上，Banana Pi只负责[拨号、路由和X墙](../../../2016/12/anti-gfw-router-on-banana-pi-r1/)。

有了隧道，我之前是写了一个pac文件，把公司常用的几个顶级域名全部走代理，浏览器之类能支持pac文件的程序就能工作了，但程序如果不支持pac文件就歇菜了。要实现无缝访问，还需要做几件事。

* DNS解析。内网资源的域名只有内网的DNS服务能解析，这也可以通过frp解决，在占美x86小主机上开一个非标准端口，比如6001，加上之前说的反向代理，frp客户端侧的配置文件如下：

```
[common]
server_addr = ip.address.at.home
server_port = 7000

[http_proxy_on_windows]
type = tcp
remote_port = 6001
plugin = http_proxy
use_encryption = true
use_compression = true

[socks5_proxy_on_windows]
type = tcp
remote_port = 6002
plugin = socks5
use_encryption = true
use_compression = true

[dns_proxy_on_windows1]
type = udp
remote_port = 6001
local_ip = dns.server.ip1.at.company
local_port = 53

[dns_proxy_on_windows2]
type = udp
remote_port = 6002
local_ip = dns.server.ip2.at.company
local_port = 53
```

* 再通过[dnsmasq](https://github.com/imp/dnsmasq)把那几个内网域名指向该非标准端口就可以了，其他默认的不变：

```
server=208.67.222.222#5353
server=/.domain1.com/127.0.0.1#6001
server=/.domain2.com/127.0.0.1#6001
server=/.domain3.com/127.0.0.1#6001
server=/.domain4.com/127.0.0.1#6001
server=/.domain5.com/127.0.0.1#6001
server=/.domain6.com/127.0.0.1#6001
```

* 分流。本来已经在Banana Pi强制所有海外IP走代理，现在只要把内网资源的IP分流到占美主机上的socks5端口即可。在Banana Pi上编译一个[redsocks](https://github.com/darkk/redsocks)，redsocks可以把流量导到socks5端口。再修改一下iptables设置：

```
-A SS -d 127.0.0.0/8 -j RETURN
-A SS -d 192.168.0.0/16 -j RETURN
-A SS -d 169.254.0.0/16 -j RETURN
-A SS -d 224.0.0.0/4 -j RETURN
-A SS -d 240.0.0.0/4 -j RETURN
-A SS -p tcp -d 10.0.0.0/8 -j REDIRECT --to-ports 58096
-A SS -p tcp -d 173.36.0.0/14 -j REDIRECT --to-ports 58096
-A SS -p tcp -d 172.0.0.0/8 -j REDIRECT --to-ports 58096
-A SS -p tcp -d 171.70.124.0/14 -j REDIRECT --to-ports 58096
-A SS -p tcp -d 72.163.0.0/16 -j REDIRECT --to-ports 58096
-A SS -p tcp -j REDIRECT --to-ports 58097
```

其中58096是redsocks开的端口，58097是统一海外代理。

这些步骤之后，所有从R6300v2走的设备都能享受到正确的DNS解析和TCP分流，不需要pac文件，浏览器、IM都能正常访问到内网资源。