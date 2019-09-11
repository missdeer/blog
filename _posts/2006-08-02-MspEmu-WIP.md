---
layout: post
author: missdeer
title: MspEmu W.I.P.
categories: 
 - imported from CSDN
description: MspEmu W.I.P.
tags: 
---

原来在getglobal 函数名前，loadfile 后，要先pcall 一次，0参数的，然后就可以正常地调用脚本中的函数了。这点白天就想到了，晚上回到家，看到mail list 上也有人说了。

现在对于Lua要实现的嵌入需求，所有的技术点都已经掌握了。现在的做法是让脚本中定义带一个参数的名为main 的函数，host application 会把原始数据做为参数传进去，再调用这个函数，并且会再提供几个接口操作显示用的ListView。剩下的就是把这些用于操作 ListView 的函数补充完整。有一点感触是，资料还是少了点，另外就是看了最经典的两部相关的参考，Lua Reference 和Programming In Lua，对于嵌入C的部分，都只是单方面地介绍了C 的API，却没有提到这种情况下Lua 脚本应该怎么写。去网上搜了一下，几乎都是这个毛病。另外还有一点是，这里带的例子是用C提供扩展，用一个static 的全局函数，然后网上绝大多数的相关文章都是一样的，却没有提到如何用C++来提供封装（还是有一个gameres 上的blog 提到了）。

关于嵌入Tcl部分，可以调用到host application 中的函数了，但还没看怎么传递一片数据给脚本，也还没看到怎么调用脚本中的一个函数。主要是Lua中是这么处理的，就想在Tcl 和Python 支持中也这么处理，host application 和脚本约定好，会调用一个固定名字的脚本中的函数，并传递一些数据进去，host application 还会提供足够用于操作ListView 的接口。

看了一些Boost::Python库的使用例程，这个封装太牛了！不过网上也看到过类似这个的对Tcl 的封装，但是对于我这个小程序，根本没必要提供这么全面的交互能力，所以也不想再额外加个dll了，就自己手动加些代码了。
