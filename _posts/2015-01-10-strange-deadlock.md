---
layout: post
title: "奇怪的死锁"
categories: coding
description: 奇怪的死锁问题
tags: Linux deadlock process
---
之前一段时间一直遇到一个问题，假设有L和R两个程序，L负责启动R，杀掉R，或者在R异常退出时自动重启R，众所周知在Linux上一个程序要运行另一个程序，是先fork，然后exec执行另一个程序代码。于是问题来了，大绝大多数情况下L和R都如预期地运行，但有时候会出现R没被运行起来，用ps看是两个L在跑，也就是说fork了之后没执行到exec那儿！

众所周知，很多资料上都会提到，要调用fork的程序最好不是多线程的，因为fork后只有调用fork的那个线程还在，其他线程都蒸发了，如果其他线程中加了锁，在fork时却没解锁，然后fork的那个线程如果要加锁，那就死锁了。所以有的资料上说，即使程序一定要是多线程的，尽量在fork后立即调用exec，避开死锁的风险。

昨天那个问题又出现了，我用gdb attach了那个子进程，发现居然是死锁了，死锁在我自定义的SIGTERM handler里销毁log4cplus的函数调用里了，那个函数从callstack看会用到pthread的某个条件锁，然后fork的线程在fork后我为了切换子进程的运行身份，调用了getpwnam，确实没有马上调用exec。但我想不通的是，为什么这个子进程会收到SIGTERM信号？这点还需要继续研究。

这个问题虽然知道了引发的原因，但我一时也没想到好的解决办法，只有个workaround，在SIGTERM handler里把会死锁的函数调用去掉就可以了。
