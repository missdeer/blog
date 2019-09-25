---
layout: post
image: https://blogimg.minidump.info/2017-12-11-replace-expat-with-libxml.md
author: missdeer
title: "将expat替换为libxml"
categories: Job
description: 将expat替换为libxml
tags: XML expat libxml
---

我们维护的项目代码量不大，冗余度倒是不低，光是XML parser就有expat，tinyxml，libxml以及一个自己（其实好像是另一个第三方库自带的）手写的parser。我观察了一下，觉得可以把expat和tinyxml都替换为libxml，这段时间就在做这项工作。

好在之前的人在expat之外做了一层封装，ExpatWrapper，所以只要修改ExpatWrapper就可以了，不过倒也折腾了不少时间。这个封装在Windows上是编译成一个独立的dll，导出符号跟内部使用的XML parser没有任何关系，总的说来封装效果不错。

1. 用了libxml的SAX接口，最常用部分跟expat差别不大，提供回调函数即可，回调函数的签名也跟expat的极其相似。
2. libxml有字符串和文件的解析API，对于大段的字符串也可以分chunk进行解析，相当方便。
3. libxml貌似只有char接口，expat貌似可以根据宏定义UNICODE来使用wchar_t或char的签名接口。