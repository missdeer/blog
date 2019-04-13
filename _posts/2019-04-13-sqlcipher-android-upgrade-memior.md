---
layout: post
title: "SQLCipher Android平台升级踩坑"
categories: Job
description: "SQLCipher Android平台升级踩坑"
tags: SQLCipher Android
---

公司项目里使用SQLCipher用于本地加密存储数据，之前发现在iOS上打开数据库后执行第一条CRUD特别慢，经过几番优化尝试，发现只要在编译选项指定使用[Apple Common Crypto](https://developer.apple.com/library/archive/documentation/Security/Conceptual/cryptoservices/Introduction/Introduction.html)，就能比使用OpenSSL提升100倍性能。但是Android平台上也只能使用OpenSSL，性能问题两年多来一直没解决。

一个多月前，公司的安全部门说我们用的SQLCipher版本太老了，要求我们升级，经过大半个月折腾，我们终于把它从3.4.1升级到了当时最新的4.0.1，相关人士都欢欣鼓舞，直到这个星期。

Android team为了适应Google play的要求，把API target升级到了28，显示通知栏图标的逻辑变成了先调用[startForegroundService](https://developer.android.com/reference/android/content/Context.html#startForegroundService(android.content.Intent))再调用[startForeground](https://developer.android.com/reference/android/app/Service.html#startForeground(int,%20android.app.Notification))，结果在这两次调用中间，因为执行数据库的初始化读写操作，导致两次调用时间间隔超过5秒（SQLCipher就是这么慢！），App被系统干掉！于是开始了我们在Android上的优化。

鉴于一直没有更好的像[Apple Common Crypto](https://developer.apple.com/library/archive/documentation/Security/Conceptual/cryptoservices/Introduction/Introduction.html)方案，我们直接放弃了提升SQLCipher性能的尝试。而是把所有数据库初始化操作都放到后台线程，然后把几乎所有相关的读写操作都加了锁（简单粗暴）。而后又发现还有主线程会有数据库操作在等后台线程初始化的锁，于是还是很容易遇到[ANR](https://developer.android.com/topic/performance/vitals/anr)。最后实在没办法了，尝试把SQLCipher又回滚到3.4.1版本，发现一切都变好了！就是这么神奇！我看github上也有人报[SQLCipher 4.0.1在Android上插入数据很慢](https://github.com/sqlcipher/android-database-sqlcipher/issues/411)，官方并没有好的解决方案，给出的[关掉内存清扫的安全选项](https://github.com/sqlcipher/android-database-sqlcipher/issues/411#issuecomment-454191235)我测试下来并没多少改善。

吃一堑，长一智。这给我们的教训是：升级第三方库要尽量放在每个release开始时做，做完了还有较多的时间进行内部测试，发现问题最差也能回滚到之前的状态。

