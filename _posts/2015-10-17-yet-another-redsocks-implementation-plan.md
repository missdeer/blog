---
layout: post
title: "计划做个类Redsocks的新实现"
categories: Coding
description: 计划做个类Redsocks的新实现
tags: redsocks Go GFW gateway shadowsocks
---
前段时间用ss-redir实现了后端是shadowsocks的翻墙网关，虽然真的实现了全局域网自动翻墙，但仍然留下了各种不足。

比如对shadowsocks服务器的负载均衡支持不足，比如配置麻烦，比如不能方便地查看运行状态等等。于是我就想是不是自己用Go实现一个类似功能的东西，它需要这些功能：

- 后端支持http connect/http relay/socks4，4a，5/shadowsocks，本来redsocks2说是都支持这些了，我实际用来发现对shadowsocks支持不稳定，于是我现在都是用ss-redir做的。
- 多服务器负载均衡。这是我特别需要的一个功能，因为我现在搞到十多条shadowsocks线路，有付费和免费的，线路质量都还不错。但是我这里对负载均衡的策略会很奇怪，估计到时候只能满足我一个人的需求。比如我现在使用的免费线路是有流量限制的，所以这个应该在负载均衡里体现出来，还因为有日本，香港，新加坡，美国等各地的服务器，所以希望能根据访问的目的IP所在地来区分使用就近的服务器线路，还因为听说有人因为用roundrobin策略导致twitter账号被suspend，所以希望在前一条规则的前提下再加一条根据C网IP段还做个hash来调度，如此等等。
- 它能跑在Linux以外还支持Mac以及几大主流BSD系统，redsocks倒是设计得支持Linux和FreeBSD、OpenBSD，但ss-redir只支持Linux。
- 也许在Linux上，我还想让它同时支持NAT和tproxy两种工作方式。目前貌似redsocks和ss-redir都只支持NAT，而xsocks是用tproxy的。
- 它有一个管理配置端口，通过socket来下发更新配置和查询工作状态。
