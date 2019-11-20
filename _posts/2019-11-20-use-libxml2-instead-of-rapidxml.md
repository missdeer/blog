---
image: https://blogimg.minidump.info/2019-11-20-use-libxml2-instead-of-rapidxml.md
layout: post
author: missdeer
featured: false
title: "使用libxml2替换rapidxml"
categories: job
description: 使用libxml2替换rapidxml
tags: libxml2 rapidxml
---

自从知道[rapidxml](http://rapidxml.sourceforge.net/)以来，我就一直尽量在需要XML parser的地方用rapidxml，我能说出好几个理由为什么用rapidxml而不是其他的诸如[tinyxml](https://github.com/leethomason/tinyxml2)，[msxml](http://msdn.microsoft.com/en-us/library/ms763742.aspx)，[xerces-c++](https://xerces.apache.org/xerces-c/)，[expat](https://github.com/libexpat/libexpat)等等，比如：

* 实现非常小，核心只有一个头文件，非常容易集成到项目中
* 运行速度非常快，用C++的人不就往往自觉不自觉地非常看重运行性能嘛
* API设计非常易懂，上手容易
* 跨平台，比如msxml就只有Windows上能用，还要用COM的那种方式导出导入头文件
* 被boost引入使用，代码质量基本上得到了证明

但是这几年在公司项目中我尝试将所有XML parser都替换成rapidxml时，却遭到了两次现实的铁拳：

1. rapidxml parser只有DOM接口，没有SAX

2. rapidxml_print功能太弱，甚至选项没做到与parser的一一对应

   除此之外，还有其他一些问题，例如：

3. 功能太少，比如无法处理HTML的情况

4. 每次分配内存都要调用库中的方法，而且还往往要精确指定大小

5. 已经10年没更新啦！

这次是遇到了第二个问题，每次将DOM树转成XML字符串时，发现rapidxml_print总是自做主张多做一次特殊字符转义，而在parser中却是有一个参数可以强制忽略可转义的特殊字符的。想来想去没找到简单的办法，于是只好再次投入[libxml2](http://www.xmlsoft.org/)的怀抱。

其实我是不喜欢libxml2的，原因是：

1. API是C的，而我更喜欢C++，真是不习惯把对象指针作为函数第一个参数传进去
2. 运行性能略差
3. 之前还被坑了在多线程环境中莫名其妙crash，至今没找到原因，也没找到解决方案，当时的workaround就是用rapidxml实现了一遍

不过这次的需求环境限制比较严格，比如只会跑在主线程，会要处理HTML文档，于是用libxml2实现了一遍，所有问题都解决了。