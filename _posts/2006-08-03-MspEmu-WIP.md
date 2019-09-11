---
layout: post
author: missdeer
title: MspEmu W.I.P
categories: 
 - imported from CSDN
description: MspEmu W.I.P
tags: 
---

界面稍微改了一下，把协议模拟的按钮和菜单项隐藏起来了，因为肯定没时间做了，另外在工具栏上添加了个按钮，可以拉出菜单，选择运行插件。

Tcl 嵌入部分也做得跟Lua 一样了，剩下的就是增加操作ListView 的接口了。

Python 嵌入遇到了困难，它的嵌入和扩展比起Lua 和Tcl 来，真是太复杂繁琐了！想让它直接运行脚本文件，但是调用 `PyImport_Import（）`时，死活返回一个NULL，郁闷，google 上搜了一把，好像没有和我相同原因的这种现象，只好先去mail list 问一下，看看有没有办法。如果实在没办法解决，还有一条退路可走，不过比较笨：自己把文件内容读出来，当作一个字符串块提交给Python 解释器执行。期间还遇到一个问题，如果用debug 模式编译时，在连接阶段，会报找不到`__Py_Dealloc` 之类的符号，看一下从python24.dll 中导出的符号，也确实没有这些，把程序改成用release 编译就好了，大概那些符号只有debug 版本的dll 文件才导出。

如果`PyImport_Import`的问题能解决，应该最多在明后两天，就可以先release 一个版本了，可用于提交评审了，今天才被催了，这个季度要最晚10号前提交！

今天去沟通了，比预计的多了一点点，我太容易满足了，当时甚至想一直就这样待在这里了。
