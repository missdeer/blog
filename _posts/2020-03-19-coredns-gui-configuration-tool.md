---
image: https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-19/mainwindow.png
layout: post
author: missdeer
featured: false
title: "CoreDNS图形化配置工具"
categories: Shareware
description: 写了一个简单的图形用户界面的CoreDNS配置文件生成工具
tags: CoreDNS Qt
---
总共花了十几个小时用Qt写了一个简单的、具有图形用户界面的、CoreDNS配置文件生成工具，只有一个主窗口，传统widget比较丑：

![主窗口](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-19/mainwindow.png)

该工具生成的配置文件需要配合经过我[修改的CoreDNS版本](https://github.com/missdeer/coredns_custom_build)使用，因为用到了一些官方版本没有的插件。方便起见可以直接调起CoreDNS，为了能在Windows监听53端口以便可以直接在网络连接中设置为DNS Server，所以启动的时候需要管理员权限。

写得比较随意，各种细节都不完善，只能说基本能工作了。目前仅在Windows上经过实测，理论上macOS/Linux等平台也是可以使用的。

自我感觉目前修改过的CoreDNS已经很好用了，而且还能享受上游非常活跃的更新，不过最近还想加个类似官方forward的插件，要支持DoH和DNSCrypt，虽然我觉得这两个都没DoT好，要能同时向所有上游服务器请求，返回最快返回的或返回TCP连接速度最快的结果，这个也许有点实用价值。