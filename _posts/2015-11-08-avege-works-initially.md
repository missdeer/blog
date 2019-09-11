---
layout: post
author: missdeer
title: "Avege初步能工作了"
categories: Shareware
description: Avege初步能工作了
tags: Go GFW raspberrypi gateway redsocks shadowsocks
---
之前说过想做个类redsocks的实现，纠结了一些天看代码后，现在终于用Go做了个初步能工作的版本出来，名字叫Avege，依然是某[女推友](https://twitter.com/avege)的id。

现在只实在了最基本的proxy功能，包括socks5和redir两种模式，能使用多个服务器做fail over，其中redir模式只支持Linux，后端服务器只支持shadowsocks，其他的都还没做。

接下来要实现最高优先级功能：

- 从控制服务器处获取服务器列表和更新的iptables配置
- 上报流量使用情况到控制服务器
- 跟控制服务器有个鉴权过程，可以限制客户端的流量使用配额
- 更智能更高效的多服务器load balance

之后是优先级不那么高的功能：

- 专门的app连接控制服务器，分管理员版本和客户版本
- 后端能支持socks/http等传统proxy
- 支持pf，ipfw等防火墙，也就是Mac OS X, BSD系列
