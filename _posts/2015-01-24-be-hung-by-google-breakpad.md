---
layout: post
author: missdeer
title: "程序被Google Breakpad挂住了"
categories: Job
description: 程序被Google Breakpad挂住，退出不能
tags: breakpad cpp
---
很长一段时间来，一直偶尔有发现进程在收到SIGTERM或SIGKILL后，仍然不能完全退出。之前总以为是sighandler写得有问题，还怀疑过是SIGTERM不够强力，需要用SIGKILL，事实证明其实都没关系。

前段时间还在网上看到Apache httpd server在让子进程退出时的做法，因为貌似它也有偶尔不能完全退出的情况，于是他们就先发个SIGTERM，过1秒钟如果发现进程还在，再发一个SIGTERM，如果再过3秒钟进程还在，就最后发一个SIGKILL强制退出。于是我也照这个样子做，但是现在看来仍然会有退不出的情况。用htop看那个残留的进程从n个线程变成1个线程了，用gdb attach上去看一下那个线程的callstack，发现这样的东西：

```
(gdb) bt
#0  0x00000000004c6650 in sys_read (this=0x2370920) at ./src/third_party/lss/linux_syscall_support.h:2838
#1  google_breakpad::ExceptionHandler::WaitForContinueSignal (this=0x2370920) at src/client/linux/handler/exception_handler.cc:519
#2  0x00000000004c670d in google_breakpad::ExceptionHandler::ThreadEntry (arg=<value optimized out>) at src/client/linux/handler/exception_handler.cc:379
#3  0x00000000004c6a4a in sys_clone (this=0x0, context=<value optimized out>) at ./src/third_party/lss/linux_syscall_support.h:2010
#4  google_breakpad::ExceptionHandler::GenerateDump (this=0x0, context=<value optimized out>) at src/client/linux/handler/exception_handler.cc:474
#5  0x0000000000000000 in ?? ()
(gdb) info thread
* 1 process 6804  0x00000000004c6650 in sys_read (this=0x2370920) at ./src/third_party/lss/linux_syscall_support.h:2838
```

可以看到程序是被Google Breakpad的某个方法`google_breakpad::ExceptionHandler::WaitForContinueSignal`挂住了。在网上搜了一下，也没发现什么有用的信息，在Stackoverflow上看到[一个问题](http://stackoverflow.com/questions/26631816/child-hangs-if-parent-crashes-or-exits-in-google-breakpadexceptionhandlersig)，也提到进程被这个方法挂住了，但他出现的场景跟我完全不一样，而且还没下文了。

目前我也没头绪怎么可以比较完美地解决这个问题，实在不行就只好在发布版本中不带breakpad了，毕竟现在在生产环境中程序几乎不会意外crash了。
