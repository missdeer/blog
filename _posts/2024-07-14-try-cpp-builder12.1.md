---
image: https://blogassets.ismisv.com/media/2024-07-14/bds.jpg
layout: post
author: missdeer
featured: false
title: "C++ Builder12.1试用体验"
categories: Editor，IDE
description: C++ Builder12.1试用体验
tags: C++ software
---
这几天突然又想试试C++ Builder，现在最新的版本是12.1。曾在大学时使用C++ Builder 6写过一些小程序，这么多年过去，源代码丢掉了一些，还能找到一些。用12.1是不能直接打开6.0的工程文件的，需要新建VCL工程，再把窗体文件、源代码文件和头文件添加进去，才能编译。12.1的VCL整体上变化不大，主要是字符串类变成了UnicodeString，以前的C++ Builder和Delphi在字符编码方面的支持确实是一大弱项，项目代码拷过来后，主要就是字符串部分需要修改一下。
6.0的时候编译器就是Borland经典C++编译器，曾经是能与微软扳手腕的存在，12.1中虽然仍然保留了这个经典编译器，但已经不推荐用了，它只能生成32位代码，而且对C++新标准的支持也没跟上，C++ Builder几经易手，后来基于Clang 5这个版本魔改实现了对VCL的支持，以及跨平台目录代码编译的支持，不但能生成Windows可执行代码，还能生成Android，Linux，iOS，macOS的可执行代码，而且Windows平台上还同时支持生成32位和64位代码，都是得益于Clang这个编译器。12.1版本在Windows平台上共有3套编译器，分别是经典32位编译器bcc32，基于Clang 5的32位编译器bcc32c/bcc32x和64位编译器bcc64，以及基于Clang 15的64位现代（modern）编译器bcc64x。
具体使用哪套编译器，要根据自己的实际需求来考虑。一般说来32位编译器生成的可执行文件比64位的文件体积小很多，但64位的程序可以使用更大的内存以及更宽的处理位宽带来的更快的运行速度。所以我觉得如果要编译32位程序，则使用基于Clang 5的编译器，如果要编译64位程序，则使用基于Clang 15的现代编译器。有个需要注意的是，64位现代编译器刚上市，有不少小问题，比如不能动态链接VCL的运行时DLL和BPL，默认会把调试符号打进exe文件导致文件体积暴增（可在链接命令行中增加`-pdb nul.pdb`规避），暂时不支持CMake构建，编译速度慢等等。
C++ Builder 12.1还集成了MSVS上的强力辅助插件[Visual Assist X](https://www.wholetomato.com/)，我也是这才发现原来小番茄不知道什么时候已经被Embarcadero收购了。曾经C++ Builder 6上的自动完成非常快且可靠，自那以后慢慢就废掉了。现在集成了小番茄倒是有所改善，但还是很容易就不工作了，需要在工具菜单上选择清理VA缓存，再重启BDS，重建VA索引，才能重新工作。
总体上，写一些简单UI的Windows程序使用C++ Builder还是很方便的，可以生成体积较小的本地代码，但是这个IDE本身质量方面比较差，勉强用用还可以。真是怀念Borland时代的产品啊。