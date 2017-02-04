---
layout: post
title: LLYF ProcessHelper W.I.P.
categories: 
 - imported from CSDN
description: LLYF ProcessHelper W.I.P.
tags: 
---

在VCKBASE 上看到一段代码，觉得好玩，打开VC2005 试了试，得出一大堆数据来，高兴死了。于是想增强一下ProcessHelper，把代码从VSS 里Check out，打开BDS2006来，整了一会，发现有一部分代码总是工作不正常，而同样的代码在VC2005 里面却工作得好好的，这是怎么回事！不禁又要抱怨一番，总感觉除了VCL，Borland 的C++ 编译器套件不如Microsoft 的好用（其实是我自己的问题啦）！稍微仔细地观察一下问题现象，发现似乎是结构体里面引用成员变量时错位了。我马上想到，是不是字节对齐的缘故。然后加上调试语句，看这个结构体的大小，果然在BDS2006里是 56bytes，而VC2005里是64bytes，差了整整8个字节，还以为是编译选项没选好，就在这个结构体声明的地方加了强制8字节对齐。试了试，还是老问题。于是索性在使用这个结构体的地方，把各个成员的起始地址都打印出来看，好像两边都一样。后来，想想用sizeof看看里面各个成员变量占用多少空间，发现BDS2006里最后两个成员，都只占用1byte，而VC2005里都占用4bytes！看到这两个变量的类型，都是枚举类型，突然想起C++ Builder里有个编译选项可以设置是否把枚举类型当作整型来处理，找了一会，勾上这个再编译，运行，果然好了！

最近在用ProcessHelper的时候，它总是弹出访问违例的异常消息框来，我把所有的大的处理函数都套上try…catch，也不见效，后来在 BDS2006的调试器中运行时发现，是在一个给Virtual ListView 添加内容的函数中抛出的异常，在这个函数中，使用了STL 中的vector，把vector里的内容依次取出，添加到ListView 中显示出来，也不知道是操作vector 时有问题了还是过多地添加ListItem 时有问题了，尝试把后面几个子项屏幕掉，还是会有问题。后来一想，太傻了，直接给这几句套上try…catch不就行了！

其实很多时候，都是使用者自己的问题啊！Just take a screen snap！

\includegraphics[width=15cm]{ph.jpg}
