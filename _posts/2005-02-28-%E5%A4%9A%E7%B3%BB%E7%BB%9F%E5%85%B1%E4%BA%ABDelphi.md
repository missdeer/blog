---
layout: post
image: https://blogimg.minidump.info/2005-02-28-%E5%A4%9A%E7%B3%BB%E7%BB%9F%E5%85%B1%E4%BA%ABDelphi.md
author: missdeer
title: 多系统共享Delphi
categories: 
 - imported from CSDN
description: 多系统共享Delphi
tags: 
---

完成多系统共享BCB6之后，我开始尝试多系统共享Delphi 7 Studio Enterprise （简称D7）和Delphi 2005 Studio （简称D7）。

像多系统共享BCB那样添加Path和注册表项后，点击Delphi 的运行文件，在D7时，会直接弹出对话框，说不能找到有效的许可信息，直接要求退出。 D9 则是在显示Splash 窗口时，弹出几个MessageBox，说某某类没有注册，然后会一直停在那里，没用进度。

然后上网找了个D7 的Keygen，是个Console 程序，运行时会从屏幕上显示几行字，就是注册码和认证码，还会在Keygen 的相同目录下生成一个后缀为.slip 的文件，把这个文件粘贴到D7的bin文件夹下，就可以运行delphi32.exe 了。

再上网找了个D9 的Keygen，这个Keygen 可以直接点击Register 按钮注册（这时要关闭D9 主程序），另外，因为D9 用到了.NET Framework，所以要把bin 目录下的那些程序集添加到系统中，打开控制面板-管理工具-Microsoft .NET Framework 1.1 Configuration，在左边树视图中选Assembly Cache，在右边Add an Assembly to the Assembly Cache（也就是添加程序集，如果用的是Win2003 中文版，就会看到用的是中文），然后到D9 的bin 文件夹下选所有文件（主要是这样方便一些）添加，这时会有一些MessageBox 弹出，说不是什么有效的程序集，或是要求要Strong name 之类的，不用管，直接点确定就是。完了，就可以运行bds.exe了，这时会有一些MessageBox弹出，说某某类没有注册云云，不用管，点确定，之后，就会进入程序主界面了。
