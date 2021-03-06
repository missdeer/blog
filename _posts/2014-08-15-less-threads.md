---
layout: post
image: https://img.peapix.com/16026754740830563107_320.jpg
author: missdeer
title: "更少的线程"
categories: Job
description: 程序使用更少的线程
tags: multithreads
---
之前说过，Relay项目要重构，第一件事就是要把每个程序的线程数减少，甚至改成单线程的。最近这一周全都在做这件，略有成果。

- 程序d剩下2个线程，这个程序是个纯粹的TCP server，所以结构最简单。一个线程是log4cplus用于监控配置文件变化并应用新配置的，另一个线程就是server所用的io_service线程了。

- 程序t剩下3个线程，同样一个线程是log4cplus的，一个线程用于通过TCP socket作为IPC client来从d获取信息的io_service，还有一个线程是Boost.asio特有的让client的io_service有点事做不至于run退出的work线程，是Boost.asio自己生成的。

- 程序c剩下4个线程，一个是log4cplus，一个是IPC client的io_service，一个是client io_service的work，还有一个是用于HTTP server的io_service。貌似Boost.asio用于client侧和server侧的io_service不能共享同一个对象，不然处理了一个handler可能下一个handler就被阻塞了。这件事情我不是很确认，但至少我一直遇到这个问题。我也想不通，为client用的io_service也同时可以给其他的诸如timer之类的用，而为server用的io_service也可以同时为acceptor和新创建的connection socket所用，但这两个为什么不能同时用呢！

- 程序l剩下4个线程，一个是log4cplus，一个是IPC client的io_service，一个是client io_service的work，还有一个是用于监控进程退出事件的netlink循环。本来netlink也是通过socket API来实现的，也许是可以直接用Boost.asio的io_service来处理，但是想想Windows下的RegisterWaitSingleObject和BSD系的kqueue可不一定能很方便地跟Boost.asio一起协作，于是先多个线程吧。

这些事情还是比较容易的，余下的就相对要复杂多了。一是重构IPC协议，我简单看了一下，至少d，c，l的IPC部分是要改的，思路还没理清，也不知道有多少复杂度。另一个是程序r从select改成全Boost.asio以提高吞吐和降低CPU，这件事就更复杂了。只能慢慢来吧。
