---
layout: post
image: https://img.peapix.com/5188676692296367197_320.jpg
author: missdeer
title: LLYF SocketCapture W.I.P.
categories: 
 - imported from CSDN
description: LLYF SocketCapture W.I.P.
tags: 
---

用鱼鱼桌面秀装扮了一下桌面，视觉效果不错，不过最大的一个毛病，就是总要把程序焦点抢过去，所以导致有时候为了做点事情，不得不先把它关了。这样一来，它就真的只是个中看不中用的东东了。另外就是，它居然用Object Pascal作为它的脚本语言扩展，好像InnoSetup也是用OP，网上有个RamObjects的project，不知道有没有什么联系。鱼鱼提供了一大堆的函数，不过看了一下论坛上的扩展，似乎绝大部分第三方的插件都仅限于在官方插件的基础上换个皮肤，没有其它更有创意的东西了。以前用鱼鱼日历秀的时候，在Windows的进程管理器中看到它占用的内存很小，很惊奇，昨天才用LLYF ProcessHelper看了一下，其实它占用的内存峰值还是超过30MB的，估计是不停地调用EmptyWorkingSet造成占用物理内存低的假象吧。

好了，言归正传，这几天又把LLYF SocketCapture拾了起来，而且除了界面布局有点是沿用以前的之外，其它的都是从头来过的。因为以前的那个通过Hook API来实现的方案，在有几个WinSock API被hook时，会让被hook的进程崩溃。这次决定把它做成有几种模式的，网上也可以看到各种文章，谈到数据包截获的几种方式。一种是用 WinPcap实现，可以截获从传输层到数据链路层的报文，一种是用hook API，应该算是应用层的劫持方案，还有一种是用raw Socket，可以截获传输层和网络层的报文。当然还有其它的一些方案，比如用NSIS驱动，SPI等等。有点郁闷的是，我这机器上，每次用raw Socket来嗅探数据报文的时候，总是没几秒钟就搞蓝屏了。这很奇怪，我用的Windows XP SP2，在Windows Update上的补丁基本上都是自动打全了的，硬件上用IBM T43，应该都是主流的经过考验的啊！唯一可以再怀疑一下的是，开了Kaspersky 5.0，这个是网上找的，脸红一下！一个Ring3级的应用程序，能弄出蓝屏来，还是恐怖的！我一直在往那个方向发展，所有使用的软件都是正版的，如果不想买正版，就自己写，自己实在也不出来，就只好去找crack了。现在为止，杀毒软件写不出来，VS、BDS这样的开发工具写不出来，其它的基本上都可以用免费的替代品。要么自己写，就像这个LLYF SocketCapture，在网上看到一个WinSock API hook的工具，要几百RMB，自己动手，丰衣足食。主要是这个东西一直在那里放了一年半了，现在觉得要实现的技术点都掌握了，剩下需要的是时间和精神支撑了，呵呵。
