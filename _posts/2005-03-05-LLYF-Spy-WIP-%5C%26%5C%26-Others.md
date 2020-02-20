---
layout: post
image: https://img.peapix.com/10312363770533851455_320.jpg
author: missdeer
title: LLYF Spy WIP && Others
categories: 
 - imported from CSDN
description: LLYF Spy WIP && Others
tags: 
---

今天看了一下Shotgun 那个端口进程关联的代码，那是在Win2000 下可以运行的，虽然得不到(System)8\#进程的信息，但可以在普通账号下运行。到XP 下有点小问题，只是因为2000 和XP 对句柄类型表示的枚举值不同，2000下是0x1A，而XP是经0x1C，改了就可以像2000下运行了。

于是我把这部分代码加到LLYF Spy 里去，用一个TListView 来显示信息，结果，有点怪的是，在XP下（因为现在在XP 下用BCB）假如是得到一个有效的Socket 句柄，要添加到TListView 中去，如果直接有SubItem 添加，则卡巴斯基那服务进程kavsvr.exe 会不能OpenProcess，错误类型为5，但如果不加SubItem，即使只加Caption，则也可以全部显示出来，真是怪事。

后来，我的解决办法是，先开一个结构数组，把所有需要显示的信息都存入这个数组中，然后等所有端口进程关联信息取完后，再把这数组中的内容添加到TListView中，真是让人郁闷的事啊。

另外，今天发现，用PSAPI 会比ToolHelp 少枚举一些进程，比如kavsvr.exe 就没有，还有一些0\#，8\#（2000下8\#，到XP是4\#）进程也不能枚举出来，所以，为了像系统中和任务管理器那样，是还是要用ToolHelp 的。但是，现在很多木马啊什么的，都可以通过一些手段把自己的进程隐藏了，用ToolHelp 这些就查看不出来了。是真的隐藏进程，而不是像DLL 注入之类的无进程。

不过呢，kavsvr.exe 和kav.exe 真是的，用PSAPI 和ToolHelp 都打不开进程，想枚举它的Module都不行，所以连路径也找不到。不过偶然地发现，能用消息钩子把DLL 注入到kav.exe 进程空间里，呵呵。但kavsvr.exe 是个服务进程，就注入不了了。

所以我就想找个能获得比Debug 还要高的权限的方法，好像是Single吧。不过看来看去，网上的代码开放的都只能获得Debug 权限，而Single 权限的只有Patch 内核的ShellCode，而且语焉不详，似乎从2000 到XP，还有2003，都有不同的地方，比如某些关键内核参数的绝对地址不一样等等。

看了一些安焦论坛上的文章，看到那些牛牛们都提到一本书，《Windows NT/2000 Native API Reference 》，上Google 搜了一把，找到一个英文PDF 下载的，下来看了看，好像讲的都是些ntdll.dll里导出的一些函数的参考，又看看MSDN，基本上没有这类函数的说明，原来这就是Native API呀！

昨天在给LLYF Spy 添加TrayIcon 上的Balloon ToolTip，于是在翻MSDN，翻了几下偶然地发现了一篇Creating Custom Explorer Bars, Tool Bands, and Desk Bands，hoho~~~ 原来XP下的快速启动栏，输入法栏，还有WMP那酷酷的操作栏都是这样做成的呀！不过命苦的是，我对COM一窍不通，还是不能实现像WMP 那样的特性。
