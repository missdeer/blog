---
layout: post
image: https://img.peapix.com/7013184973181162642_320.jpg
author: missdeer
title: "OpenVPN同时监听TCP和UDP端口"
categories: network
description: OpenVPN同时监听TCP和UDP端口
tags: OpenVPN TCP UDP
---

在路由器上部署了全局翻墙后，出于简化部署的考虑，我把接在路由器后的一个Raspberry Pi作为VPN server，部署了OpenVPN，然后再在路由器上设置端口映射，可以从外网连回Raspberry Pi。这个方案有几个好处：

- OpenVPN相比PPTP等，自定义协议和端口更灵活方便
- 可以从Raspberry Pi直接从路由器连出上网，享受翻墙的便利
- VPN和翻墙都是要改iptables的，分开在两个设备上可以简化设置

之前用的是TCP协议，因为公司网络可能出于安全角度考虑，封禁了常见VPN协议的默认端口和协议，UDP也被封了。虽然用TCP协议连回去也工作得很正常，但我还是想在可以的时候使用UDP协议连上Raspberry Pi，比如在运营商并不对UDP协议强力QoS时，OpenVPN over UDP会有较小的latency。

要让OpenVPN同时监听TCP和UDP端口方法不止一种，我用了最简单的办法。把`/etc/openvpn/server.conf`复制一份，比如`/etc/openvpn/udp.conf`，然后修改`udp.conf`：

- 协议修改为UDP：`proto udp`
- IP地址修改略作修改，比如所有原来是`10.8.0.x`的地方，都改为`10.8.1.x`

然后修改iptables，增加一条nat规则`-A POSTROUTING -s 10.8.1.0/24 -o eth0 -j MASQUERADE`。最后，再运行一个OpenVPN进程，通过命令行参数指定新的配置文件：

```shell
/usr/sbin/openvpn --daemon ovpn-server --status /run/openvpn/server.status 10 --cd /etc/openvpn --config /etc/openvpn/udp.conf
```

这样，就应该可以以UDP协议连上server了。