---
layout: post
author: missdeer
featured: false
title: "全Go科学上网解决方案"
categories: gfw
description: 全部使用Go编写的程序实现科学上网
tags: GFW Go
image: https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-09-13/coredns.png
---

本来由于使用网关的方式进行科学上网一直工作得比较稳定，所以很久都没折腾科学上网相关的东西了。前不久用了几年的Banana Pi突然连不上了，通过socks5+pac的方式也勉强应付了。今天回到老婆娘家，发现两个月前还工作得好好的树莓派不知道什么时候已经点不亮了。不禁感叹ARM板似乎不太耐操啊，以后还是尽量只用x86的工控机之类的吧。

言归正传，随身携带的笔记本不能科学上网，可是憋坏了我这个重度Google用户，于是一顿操作猛如虎，一套全部使用Go编程的程序实现科学上网的解决方案出炉了。分别需要以下程序（都是开源的）：

- [v2ray](https://github.com/v2ray/v2ray-core) 解决内容传输的问题，暴露一个socks5端口
![v2ray](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-09-13/v2ray.png)
- [tun2socks](https://github.com/eycorsican/go-tun2socks) 解决全局流量劫持并走socks5的问题
![tun2socks](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-09-13/tun2socks.png)
- [魔改版CoreDNS](https://ci.appveyor.com/project/missdeer/coredns-custom-build) 解决DNS污染，并CDN友好的问题
![魔改版CoreDNS](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-09-13/coredns.png)
- [chnroutes webui](https://github.com/missdeer/chnroutes-webui) 解决大陆地区网络直连的问题
![chnroutes](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-09-13/chnroutes.png)

在macOS系统使用下来效果非常好。
