---
layout: post
image: https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-15/add-clang-cl.png
author: missdeer
title: "Qt Creator使用clang-cl"
categories:  CPPOOPGPXP
description: "Qt Creator使用clang-cl"
tags: Clang Qt
---

之前已经[在Windows上用clang编译Qt程序](https://minidump.info/blog/2018/07/clang-on-windows-for-qt/)，但当时的Qt Creator并没有好好地支持，所以需要在控制台上直接使用命令行进行编译。今天偶然发现最新的Qt Creator已经支持`clang-cl`套件了，试了一下效果不错。

首先，仍然是去[官网](http://prereleases.llvm.org/win-snapshots/)下载最新的LLVM预编译安装包：

![](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-15/snapshot.png)

下载后安装，我习惯用Universal Extractor直接提取出所有安装包内的文件，这样不会在注册表、各种目录中留下冗余内容，比较干净：

![](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-15/uniextractor.png)

然后在Qt Creator中进行配置，首先添加Compiler，选`clang-cl`，意思是这个clang套件是配合msvc使用的：

![](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-15/add-clang-cl.png)

再设置一下msvc环境：

![](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-15/msvc-env.png)

设置一下`clang-cl`的路径：

![](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-15/clang-cl-path.png)

这样编译器信息就设置好了。接着设置Qt Kit信息，选中msvc编译的Kit，把Compiler项`C`和`C++`都设置为前面添加的`clang-cl`套件即可：

![](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-15/kit.png)

到此为止所有设置全部完成，就可以在Qt Creator像使用MSVC套件那样编译Qt程序了。

至于我为什么要大费周章地用clang来编译Qt程序，有以下理由：

1. clang更新很积极，差不多每个月会有一个snapshot，所以可以每个月都用上最新版本的clang，满足版本控的奇怪心理。
2. clang的编译输出信息比较好看。
3. 公司项目是用MSVC2015的，只支持到C++11，如果同一系统内再装个MSVC2017，就编译不了公司的项目，而我自己的程序又要用到C++17的一些语言特性，所以用clang可以满足这个需求。但是有个限制，仍然不能使用C++17标准库中的东西。

