---
layout: post
image: https://img.peapix.com/7651317261175529775_320.jpg
author: missdeer
title: "Reactor和Proactor模式"
categories: Coding
description: 网络编程的两种模型
tags: socket network asyc IO Reactor Proactor
---
其实我大概10年前就知道ACE了，并且把国内翻译引入的3本以ACE为蓝本的讲C++网络编程的书都收齐了，之所以说是收齐，是因为自己买了两本《C++网络编程》，而由译者马维达送了一本ACE开发指南。但是三本书入手后并没有认真读过，后来工作上也跟C++网络开发基本不相关，于是一直了解不多。直到现在这份工作，虽说终于转向网络开发了，但实际上要么因为老代码已经把底层封装好了，要么就直接用了Boost.Asio而不求甚解。

前两天突然又心血来潮翻出陈硕写的《Linux多线程服务端编程》，看了几页，突然就看懂什么是Reactor和什么是Proactor了。这本书讲的多是作者的经验之谈，风格上跟神作《UNIX网络编程》有所不同，不过总的说来实用性相当高，对实际工作有非常大的指导意义。总的说来Reactor相对容易理解和容易实现一点，稍微实际一点的网络程序大多会采用的select模型，以及Linux/BSD上的性能提升的替代品epoll/kqueue，都是Reactor的实现。在一些第三方库中，如libevent，libev据说也都是Reactor模式。而Windows上的高效网络编程模型完成端口模型是Proactor模式，Boost.Asio也是Proactor模式，怪不得这么多年来我一直没弄明白更用不好。Reactor关注操作就绪通知，收到通知后程序得自己调用相应的系统API来进程IO操作，比如读写socket。而Proactor模式，国内有翻译成前摄器，感觉不是很精确得表示它的含义，只是对这个单词直译了，它关注操作完成通知，收到通知时系统已经帮你完成了IO操作，比如缓冲区里的数据已经被发送出去了或者缓冲区里已经有了接收到的数据。之前我一直疑惑的是Proactor模式下怎么决定要投递一个读操作呢，感觉接收数据这个行为如果不是应用层协议严格定义好的话，完全是个随机发生的事件，用Reactor模式才合适。我看了一点Boost.Asio的示例代码，发现这种情况他们基本上都是这样处理的：一直投递读操作，如果有写的需求了，就临时投递一个写操作，后面仍然继续投递读操作。

《Linux多线程服务端编程》一书非常值得仔细读一下，我就是在这书的引导下，对网络编程有了进一步的了解，我觉得我在公司负责的那个小工程可以仔细重构改进下，目前已经开始动手了，关于这点我后面再写一篇blog来详细讲一下这个设计抉择的演变吧。
