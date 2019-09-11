---
layout: post
author: missdeer
title: LLYFSpy wip && LLYF DebugCapture
categories: 
 - imported from CSDN
description: LLYFSpy wip && LLYF DebugCapture
tags: 
---

今天给LLYFSpy加了进程信息查看功能，可以查看当前进程所有模块信息，内存信息，文件映射，所有进程列表，服务列表，以及设备驱动程序列表，其实就是把原来LLYF ProcessHelper 里的代码搬了过来。虽说没有写新的代码，但我想这样可以给我组织程序结构有些启发。

晚上，看了一下Yonsm 的[DebugTrack](http://yonsm.reg365.com/index.php?job=art&articleid=a_20041003_184430)或[这里](http://yonsm.reg365.com/index.php?job=art&articleid=a_20041023_010315)所带的帮助文档里的原理说明，然后照着说明自己来写，还连猜带试，看IDA 反汇编DebugTrack 的代码，终于也可以捕获OutputDebugString 的输出了，写了个LLYF DebugCapture。结果上网一看，原来Yonsm 的Blog 竟然有源代码，晕死了。

另外，看到cnsw.org 上有个进程和端口关联的程序，在Win2000下也用得好好的，觉得很有趣，再次激发了我的兴趣，研究一下。
