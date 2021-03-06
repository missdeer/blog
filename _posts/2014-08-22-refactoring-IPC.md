---
layout: post
image: https://img.peapix.com/7651317261175529775_320.jpg
author: missdeer
title: "重构IPC协议"
categories: Job
description: 重构IPC协议
tags: IPC socket
---
到今天为止，IPC协议的重构也进行了一部分，效果不错。原本每秒一次的查询是否有新命令，现在使用阻塞式的查询，有新命令会立即到达，可以立即执行，原本一条新增instance的命令要大概3秒才能得到回应执行完毕，现在基本上下发命令就立即能得到回应了。同时删除instance命令也由原来的平均0.5秒耗时变成立即完成。

下一步是要实现统计数据缓存的即时刷新。当前的实现中，如果某个instance因为停止运行了而没有统计数据，d程序中得该instance的统计数据不会立即消失，而是继续使用老得数据直到3秒钟后才确认该instance是停止了，可以把缓存中的删除了。现在加了立即反馈命令执行结果，可以指导d程序即时删除数据缓存的无效内容了。
