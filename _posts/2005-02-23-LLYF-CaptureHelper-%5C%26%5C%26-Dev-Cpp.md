---
layout: post
author: missdeer
title: LLYF CaptureHelper && Dev-Cpp
categories: 
 - imported from CSDN
description: LLYF CaptureHelper && Dev-Cpp
tags: 
---

前天花了一天时间用BCB 做了个MDI界面的抓图程序，当然功能非常简单，连DX的图都不能抓，但不知道怎么的，注册热键的时候有问题，郁闷。还有就是MDI 的我用TabControl 来切换页面，想方便一点，还会发现，在切换时，桌面会刷新。晕得很。

昨天去 sf.net 上看Dev-Cpp 的更新，有4.9.9.2发布了，还有源代码的zip包下载，这下方便了，这里用拨号的速度真是慢。下载下来，依次给Delphi7 装上了各种所需的第三方控件，然后按说明编译，居然成功了，都没什么障碍，难得啊。然后我看了一下它的Forum，看到他们提到的Console 程序在Compile and Run 选项下，程序会一闪而过这个问题，Dev-Cpp 带的Example 里，都是用C库里的`system("pause")；`语句来解决这个问题的，我想可以改一下Dev-Cpp，先用Delphi 写了个executer 的Console 程序，用它来启动在Dev-Cpp 里创建的Console 程序，最后从Console 中等待读入一个字符，还算简单。不过今天看了一下sf.net 上的buglist，里面提到的bug 都很sticky，不爽啊。

还是先完善一下LLYF CaptureHelper 再说，好像用鼠标钩子`WH_MOUSE`，不能截获在标题栏，子窗口滚动条上的`WM_MOUSEMOVE`， `WM_LBUTTONDOWN`这些消息。嗯，再看看吧，至于要支持几种格式的图形文件保存，我想，用GDI+ 的编码器可以解决吧。
