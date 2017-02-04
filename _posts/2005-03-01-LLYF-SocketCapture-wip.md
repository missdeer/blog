---
layout: post
title: LLYF SocketCapture wip
categories: 
 - imported from CSDN
description: LLYF SocketCapture wip
tags: 
---

这是一个用于拦截WinSock API 的程序，主要的目的并不是为了截获数据包，而是为了能从第三方角度方便地观察二进制程序调用WinSock API 的情况，最直接最原始一点的想法，是为了能比较方便地调试自己写的Windows 网络应用程序。

关于拦截API的方法有很多种，网上各种文章到处散布。我用的是全局消息钩子注入进程空间，修改API调用地址。各种方法各有优缺点，比如修改Import Table 表，要对PE文件格式有比较深入的了解，但我不了解；Trojan DLL，要替换整个DLL，而且WinSock 有2个版本，分别对应了2个DLL 文件，一个是wsock32.dll，另一个是ws2\_32.dll，每个DLL 的导出函数有100多个，工作量太大；还有用Detours 开发包，说实话，文档不够丰富，而且1.5版还是免费使用，2.0的就要Money 了，等等等等。不是说其它方法不好，而是说，我现在采用的方法刚好比较符合我的需求，但由此带来一个重要的问题是，不能拦截Console 程序，因为没有窗口消息队列，就像现在Aweay 的MySPY 中DebugView 功能，是通过拦截OutputDebugString 这API 来实现的，所以写的Console 程序调用的OutputDebugString 是拦截不到的，不像DebugTrack，是通过OutputDebugString 的实现原理来捕捉的，可以拦截所有的输出。

曾经看到LuoCong 通过SEH 来实现API Hook 的例子程序，程序是用Win32asm 写的，看了几遍发现，似乎用Win32asm 才能比较方便地利用SEH的这个“副作用”，因为除了汇编以外，其它高级语言要获得函数的参数值很是麻烦，但或许只是因为我自己水平太臭吧，不管怎么说，反正现在我是用不上这技术了。

自从在LLYF Spy 中开始用过Hook 后，已经有点依赖这技术的感觉了，遇到什么稍微麻烦点的问题，就会想到用Hook，而且现在也有点习惯用BCB6 来编译DLL，尽管这个DLL是用纯SDK写成的，可以很方便地移植到VC 上来编译，只是因为上次遇到过的奇怪的兼容性问题，使得我把BCB 作为编译用于搭配BCB 编译的EXE 程序的DLL 的首要选择。

经过一番键盘搏击，根据自己的需求估计，Hook了24个API：recv 、recvfrom 、send 、sendto 、socket 、 closesocket 、accept 、listen 、bind 、connect 这些都有2份，wsock32.dll 和ws2\_32.dll 各1份， WSASend 、WSASendTo 、WSARecv 、WSARecvFrom 这些只有ws2\_32.dll里的那份。不过目前只是能获得API 的基本信息，像API 名字，返回值，WSAGetLastError值，PID这些。下一步的计划，是要能导出API 的调用参数列表和传输数据内容。参数列表应该不是件很难的事，而传输数据的显示，好像惯例都是用16进制加ASCII 码加偏移显示的，还要花些时间在这个上面。

另外一个问题，则是同步问题。我是用内存映射来进行进程间通信的，万一在读的时候，另一个进程在写，就不好了，所以还要找一个适当的同步机制。

最后一点，当然是稳定性，也是最重要的一点，不能因为这个进程的存在，使得其它程序也牵连受影响。
