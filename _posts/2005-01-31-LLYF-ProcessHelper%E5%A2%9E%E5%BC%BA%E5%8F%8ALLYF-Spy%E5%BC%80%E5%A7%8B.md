---
layout: post
image: https://blogimg.minidump.info/2005-01-31-LLYF-ProcessHelper%E5%A2%9E%E5%BC%BA%E5%8F%8ALLYF-Spy%E5%BC%80%E5%A7%8B.md
author: missdeer
title: LLYF ProcessHelper增强及LLYF Spy开始
categories: 
 - imported from CSDN
description: LLYF ProcessHelper增强及LLYF Spy开始
tags: 
---

在CSDN的论坛上看到一些老较经典的帖子，就把代码用在自己的程序里了，给LLYF ProcessHelper 添加了一个特性，就是显示进程的完整命令行，真是个有意思的功能。不过，之后，发现VCLSkin 太不稳定了，要出错，也许是用的crack 的原因吧，索性就不用VCLSkin 了，这样程序的体积还可以小一些，速度快一些

在ccrun 的网站上，看到老妖的MiniSpy 的开放源代码版本，下载下来看了一下鼠标拖动图标部分的代码，很好玩，于是也想自己写一个类似的窗口类观察程序，结果不知道为什么，在OnMouseDown 里用SetCursor 改了光标，就会不显示光标，真是郁闷！

对比 Spy4Win，觉得大部分功能，应该都可以实现了，就是不会对IE 进行控制，估计是要通过Internet Explorer\_Server 窗口句柄得到IWebBrowser 之类的接口来进行操作。MySpy 中的功能更NB，可以直接进入可视化编辑状态， hoho~~~

还有个古怪的bug！在获取Explorer.exe 中ListView 的内容时，除了Report 模式的其它模式都不能获取，改为Report 模式就可以正常获取了，再改回去其它模式也又可以了。屡试不爽，在Win2000+ SP4 和WinXP+ SP2 下都这样，晕得很！
