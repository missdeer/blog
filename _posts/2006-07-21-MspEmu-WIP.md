---
layout: post
image: https://blogimg.minidump.info/2006-07-21-MspEmu-WIP.md
author: missdeer
title: MspEmu W.I.P
categories: 
 - imported from CSDN
description: MspEmu W.I.P
tags: 
---

看了一下把Lua嵌入到MspEmu中去，虽然从官方网站上down 到了据说是兼容BC 的编译器的二进制lib 文件，但实际用的时候似乎还是有点问题，说\_errno 的引用找不到之类的。顺便在google 上找了一下Tcl 和Python 的内容，本来这些动态语言在与应用程序交互嵌入的时候都是优先考虑 VC的，有的几乎就根本不考虑其它编译器的情况，包括Borland 的。看了一下，有两种方案，一种是，如果已经有lib文件了，但是用VC编译器生成的，就用Borland 的一个随它的C++ 编译套装一起发布的小工具coff2omf 转一下格式，因为MS的二进制映像是coff格式的，而 Borland的则是omf格式的，这样转一下就可以链接到Borland 的C++ 工具生成的项目里去了，具体我也没实践过，不知道是否能用，总之看起来似乎没什么错，有道理的。另外一种是，找到那个dll 文件，用Borland 的一个小工具impdef 导出DLL 中的函数名，然后有个tcl 写的脚本，把别名处理一下，生成一个新的函数名列表文件，用这个新文件作为参数运行Borland 的另外一个工具implib ，就可以得到一个lib 文件了，直接用implib 也可以从dll 文件导出lib 文件，但也许VC生成的dll 中导出函数名与BCC 有区别，不一定能用。

用这第二个方案，对Lua 的试了一下，能把那个dll 文件链接进来了，其它更多的还没有实践，不好说以后还有什么问题。

看到shaohui 大虾的blog 界面，很眼红，就三两下把他的都抄袭过来了，嘿嘿。
