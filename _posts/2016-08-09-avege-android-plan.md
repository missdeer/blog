---
layout: post
image: https://img.peapix.com/17190106641069884759_320.jpg
author: missdeer
title: "avege Android版的计划"
categories: Shareware
description: 移植avege到Android的计划
tags: GFW Android avege Go
---
前些天看到有人移植了[SSR Android版](https://github.com/glzjin/shadowsocksr-android)，我就顺便看了看代码，结合网上的[一篇文章](http://ct2wj.com/2016/02/28/shadowsocks-android-source-code-analysis/)，觉得似乎挺简单的，它（官方也）用Java/Scala写了个外壳和启动VPN service，其他功能是几个用C写的程序共同完成，包括redsocks，tun2socks，ss-tunnel，ss-local，pdnsd。

之前说过，翻墙主要做两件事，一是DNS无错解析，二是内容传输。

影梭（即Shadowsocks Android）及其fork们分支持UDP转发和不支持UDP转发两种情况处理DNS解析。在支持UDP转发的情况下，就把DNS解析请求通过内容传输通道转发到远端解析回来。在不支持UDP转发的情况下，由tun2socks劫持了本地的DNS解析请求到指定的网关IP和端口，其实就是本地开的pdnsd的端口，pdnsd连到ss-tunnel，而ss-tunnel又通过内容传输通道转发到远端解析回来。所以在开启UDP转发时，pdnsd和ss-tunnel可以省略。

影梭及其fork们分NAT和VPN两种模式进行内容传输。NAT其实就是我[之前的文章](/2015/09/raspberry-pi-as-a-fucking-gfw-gateway/)里说过的在Linux下通过iptables把流量导到指定的IP和端口，需要对手机root才能实现。VPN则不需要Root，但要求系统版本在4.x以上。Android系统提供了接口启动VPN service，得到一个tun fd，app可以通过这个读取tun fd获取所有试图出去的流量，tun2socks把这些流量转换成socks5协议的格式，再连接到ss-local，ss-local则试图把这些流量发送给远程服务器，为了达到这个目的，ss-local和远程服务器之间的连接的fd通过unix domain socket传给VPN service，让它不要劫持这个fd上的出流量。

反观avege当前的实现，DNS解析和内容传输基本上都有了，只不过要移植到Android上还有一些修改的工作：

- 没有实现UDP转发，我现在还没想清楚这点是否必需
- 要把跟远程服务器的连接的fd通过unix domain socket发出去
- 剥离对redis的依赖

另外一些需要改进的项：

- 没有支持IPv6
- 没有实现SSR的那些混淆和协议插件（目前它的用户越来越多了

如此，一个avege程序可以替换掉除tun2socks外的其他所有程序，精简多了。

不过计划嘛总归是计划，至于什么时候执行呢，再议了，呵呵。
