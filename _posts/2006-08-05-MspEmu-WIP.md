---
layout: post
image: https://img.peapix.com/1724855926033220373_320.jpg
author: missdeer
title: MspEmu W.I.P.
categories: 
 - imported from CSDN
description: MspEmu W.I.P.
tags: 
---

用Borland 的编译器直接编译了一个lua5.1的源代码，生成了一个lib文件，链接进我的工程里，就是不能用，工程的编译链接都可以通过，但是到运行可执行文件的时候，就直接弹出个访问违例。倒是那个我用VC7.1编译的dll 文件，从中导出一个lib 文件一直用得好好的，晕！

不死心，又试了一下Python 的嵌入。先用PEiD看了一下那次down下来的Python二进制包里的python24.dll 文件，发现是用VC7.1编译的，于是打开VC.NET 2003，建了个空的控制台工程，把帮助文档中那个例子放进去，一直提示ImportError: No module named py，上google 搜了一遍，有一个地方提到，不要import 全文件名，要把后缀去掉，试了试，果然可以了。还发现，不能用全路径，用相对路径就没问题。Python 嵌入时，输出错误信息是到控制台的，原来的工程是GUI 的，看不到控制台的错误信息，一直摸黑，只知道PyImport\_Import 失败，都不知道这个调用失败都有几种可能性。再看看如何从Python 脚本中调用C 的函数，就可以不用砍掉这部分了。

看了一下前几天写的todo list，有些可以算是完成了，还有些没有。现在看来大概分配一下，周六，把主程序都整完，周日，写演示脚本和帮助文档。主程序有这些需要做的：

1、改成Virtual ListView；

2、把输出控制台是否显示改成可以保存在配置文件中，因为除了调试脚本，没有其它需要看到它的理由；

3、有时间的话，加入一个代码编辑器；

4、交互式脚本解释器？

BTW：鱼鱼的桌面秀挺好看的，程序似乎也不错，不过居然不要钱-\_-b
