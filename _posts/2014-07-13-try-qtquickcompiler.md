---
layout: post
title: "初试QtQuickCompiler"
categories: Coding
description: 尝试了下用QtQuickCompiler编译istkani
tags: Qt QtQuick QtQuickCompiler istkani JIT C++
---
QtQuickCompiler出来有一些日子了，自从[istkani](https://itunes.apple.com/cn/app/istkani-le-tou-xing-cai-piao/id841279537)在iOS App Store上架后，就没怎么关心过Qt的进展，只是差不多每天例行扫一遍Qt的邮件列表而已。昨天心血来潮想试试QtQuickCompiler到底有多神，首先快速浏览了一下[官方文档](http://doc.qt.digia.com/QtQuickCompiler/index.html)，发现使用还是很简单的，然后开始照文档的说明一步一步操作。

QtQuickCompiler是在Qt企业版中才有的，企业版按不同的系统平台分别定价，移动版支持iOS、Android和WinRT三个平台，[打包价每月150刀](http://qt.digia.com/buy/)，对于个人开发者尤其是没用Qt开发的产品实现盈利的开发者实在是个不小的负担！最近在搞活动，前两个月只要1刀就可以了。不过还有一种不花钱的办法，就是试用，用邮箱注册一个[Qt账号](https://login.qt.digia.com/)，可得到1个月的试用license！我就是用的这个办法，登录进去可以找到Linux/Windows/Mac下的安装包，Qt或者说Digia的CDN很糟糕，在我朝经常不能找到最近的服务器，下载没速度，这得自己想办法解决。下载了安装包后，我是用Mac的，同时也把license文件下载下来，改名成.qt-license放在HOME目录下，然后开始安装。安装程序是Qt通用的Installer Framework做的，反正也就这样，前几步是确认license的，后面是选要安装的内容，我选了Android，iOS，Mac三项，还有Tools和Enterprise Addons全部。因为前面说过Qt（Digia）的CDN有问题，所以直接下载很可能没速度，好在安装程序在开始下载之前，对话框左下角有个设置按钮，可以设置代理服务器的，这个很重要，至少我不设这个东西的话下载一直是0速度，设了个代理服务器，平均速度大约在500KB/s。漫长的下载安装过程完成后，就可以正式使用了。

可以看到qmake相同目录下有一个叫qtquickcompiler的可执行文件，可以直接在terminal里运行，当然你得有license。比较简单的办法是在qmake命令行里指定参数，比如`qmake CONFIG+="release qtquickcompiler"`，更简单的办法是直接在工程文件.pro里写死`CONFIG+=qtquickcompiler`。

还有要做的是，要把所有qml文件和相关的js文件全都打包到资源里，程序里也不要用file://来加载qml文件，要用qrc://来加载。如此改完源代码，之后就可以make了。从make执行的命令行可以看到，qtquickcompiler是把每个qml文件和js文件都转换成一个.cpp文件，跟moc做的事类似的风格，然后利用C++编译器把他们全都编译成本地代码。

从官方文档的描述中可以看到，这种方法有几个好处。脚本语言常见的做法是用JIT，但这样脚本载入速度仍然不如本地代码快。其次Apple的iOS App Store的政策是app不能动态生成本地代码，貌似Windows RT也有这个限制，这个我还真不清楚，以前听说过，以为所有的脚本语言都不能用，但后来又看到有app用了python，Lua之类，不知道具体是怎么回事，这次看了这个说明才有点回过神来，原来只是限制了JIT，那么像QML那样完全用解释执行的方式就规避了这个政策。但解释执行意味着速度慢，所以用了QtQuickCompiler这种方式又可以提速了。不过QtQuickCompiler这种生成C++中间代码的方式最后仍然是通过QtQuick的运行时来执行QML逻辑的，所以速度上应该仍有相比用纯粹C++写的代码有所损失的。

我把[istkani](https://itunes.apple.com/cn/app/istkani-le-tou-xing-cai-piao/id841279537)用qtquickcompiler编译了一下，似乎启动速度确实快了一些，因为没有做实际测试，所以到底是不是心理作用也不知道了，哈哈。也该升级一下[istkani](https://itunes.apple.com/cn/app/istkani-le-tou-xing-cai-piao/id841279537)了，这段时间一直在玩go语言做web后端开发，之前定下的一些想法一直没付诸实践啊。
