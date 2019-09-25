---
layout: post
image: https://blogimg.minidump.info/2015-10-01-fedora-on-t43-as-a-fucking-gfw-gateway.md
author: missdeer
title: "T43上的Fedora做翻墙网关"
categories: gfw
description: T43上的Fedora做翻墙网关
tags: GFW shadowsocks gateway
---
今天回老家了，老家用的是便宜的移动宽带，之前用着也没多不爽，因为也一直没怎么用，就是用来看小说了，虽然也发现移动的墙要高一些，但也凑合着过了。

今天想上twitter，然后整个人不好了。因为在上海屋里整个网络是用树莓派做翻墙网关的，树莓派不是很方便地拿来拿去，于是我很有先见之明的是拿了一个装了Fedora的T43回来，毕竟也是Linux嘛。不过仍然遇到点问题，移动的DNS污染比上海电信的要严重，用dnsmasq接上游OpenDNS的5353端口也不行了，硬是要用dnscrypt-proxy才解决问题。

这Fedora做翻墙网关基本步骤是跟用树莓派是一样的，不过有几点要强调一下。

- 要确认把iptables清空，因为Fedora默认有一些规则存在，自己家用实在不需要；
- 要用dnscrypt-proxy，所以要把这个ip加到iptables里跳过；
- 要确认`/proc/sys/net/ipv4/ip_forward`的内容已经设成1了，我之前折腾了好久国内ip不能访问，国外ip走ss-redir正常访问，估计是这里引起的问题；
- 要确认把ss服务器ip在iptables里跳过了；

基本上这样就可以work了。
