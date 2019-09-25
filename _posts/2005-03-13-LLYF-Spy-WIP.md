---
layout: post
image: https://blogimg.minidump.info/2005-03-13-LLYF-Spy-WIP.md
author: missdeer
title: LLYF Spy WIP
categories: 
 - imported from CSDN
description: LLYF Spy WIP
tags: 
---

稍微整理了一下代码，把几个只用到Win32 API 的全局函数移到一个DLL 中去了，本想这样可以减小点主执行文件的尺寸，其实也小不了多少KB。网上看到一篇文章，提到VC 程序员和BCB 程序员的代码风格问题，说一般经常看到VC程序员的代码风格要好一些，我也有些感触。用BCB 这么久，还是习惯于C语言的过程式编码风格，从来也设计一个类。

现在LLYF Spy 变成一个流氓程序了，可以指定一个命令行参数AsService，就可以以SYSTEM 身份运行，另外还专门给它加了个Run 选项，可以调用系统Shell 的Run 对话框，这样通过它运行的进程都会以SYSTEM身份运行的，哈哈，还给它加了对系统服务的启动，暂停，删除以及查看描述的功能。

以后希望能改一下那个可以注册成服务的DLL 中的代码，可以变得更通用一点，多一点其它的选择。
