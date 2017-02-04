---
layout: post
title: MspEmu W.I.P.
categories: 
 - imported from CSDN
description: MspEmu W.I.P.
tags: 
---

增加了浏览脚本源代码和用外部程序打开脚本文件的功能。读文件部分直接用Win32 API 来做，感觉有点怪怪的，还是习惯用C 库，连C++ 标准库都没啥了解，也许过些天心血来潮会把它改掉用iostream 来实现吧。现在插件管理功能基本已经达到预期目标了。

另外增加了load LUA 脚本文件并执行的部分代码，但是还是得细心规划一下，有好几种方案可以实现所要求的特性，所以要好好考虑，用最简单，最不累赘，又不能太影响效率的方法。现在看来和Lua 连接的问题已经解决了，剩下的是需要熟悉Lua 的自身特性了，当然，对于Tcl 和Python 也是。相对来讲，Tcl 还是三者之中最熟悉的一个，Python 的特性太过丰富，有点让我觉得晕头转向。

已经渐渐习惯了BDS2006 的IDE 环境了，界面确实华丽，最开心的一点是编译速度加快了好多。

另外，去down 了个Inno setup 和Istool，以后就转用这个了，不用Wise 和InstallShield 了，这个免费又开源，功能也还可以，看了下cnsw.org 的论坛里，有几个调查，好像超过一半的人是用Inno 的，还有接近一半是用NSIS，剩下的才是用其它的。
