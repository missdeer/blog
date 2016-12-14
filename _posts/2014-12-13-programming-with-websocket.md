---
layout: post
title: "websocket程序开发"
categories: Job
description: websocket程序开发
tags: coding websocket libwebsockets
---
[之前提到过](http://blog.minidump.info/2014/11/recent/)在公司的一个项目里用了websocket，client侧用C++开发，选了libwebsockets，使用的过程中遇到一些问题，这一个星期都是在不停地解决各个问题，好在现在终于基本上都搞定了，现在记录下来。

我们的Client是统一由C++写的底层core，运行于多种上不同的平台之上，包括Win7，x86 Gentoo，iOS，还有arm Android和Mac OSX。前三个是第一个版本必须要支持的，也各有各的问题。我最先在Win7上跑通程序，说实在的libwebsockets的文档和示例都做得不好，我也是拼拼凑凑抄抄勉强搞定。第一个提交测试的版本居然有人说有handle泄漏，而我开发过程中却没有遇到。后来意外发现有泄漏的情况都是在连不上server的时候，这就很容易重现了。用WinDBG加载运行，输入命令!htrace -enable，过一会儿有明显的泄漏了再输入命令!htrace -diff，可以看到一堆多出来的event handle，随便找一个callstack是从libwebsockets出来的，lsa callstack地址一下就跳到创建event的源代码行了。原来在创建socket时会同时创建一个event，我试着在销毁event的函数打了断点，从来不被调用。看了一下源代码，貌似在socket销毁的逻辑里有一个条件判断写反了，改了一下试试似乎不泄漏了。

Win7上跑通后，同样的代码放到Gentoo上跑，发现死活连不上，libwebsockets内部的log也没法打出来，后来build了自带的示例才看到log说创建sockets就失败了。看了Win7上运行得好好的，用netstat看都是以IPv6的地址格式创建了连接，于是我看了一下libwebsockets的CMakeLists.txt，试着关掉了IPv6的支持，发现居然真的好了！问了下公司做Gentoo镜像的同事，原来他们把IPv6禁掉了！

终于两个平台的client可以通过server通信了，还以为完事了，又可以提交测试了。结果，一票人报告说，Win7上log显示connection error！我的开发环境怎么都不能重现，正在郁闷中，想起之前在网上看到的一个[issue](https://github.com/warmcat/libwebsockets/issues/208)，然后我就尝试着加了个sleep，居然真的好了！难道就是在网络性能略差，CPU运算性能略强的情况下会出现这个问题！关键是Linux下没这问题，难道就是Linux的网络性能够好？无法解释！

这次的经历真是有点坎坷，单兵开源项目的质量真是得用户自己承担很大风险啊！
