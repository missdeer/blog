---
layout: post
title: "imchenwen WIP"
categories: Shareware
description: imchenwen开发进度
tags: Qt Boost
---

imchenwen的进展不快，这段时间主要在做两件事：

1. 支持VIP视频，网上有很多网站可以播放VIP视频，有收费的也有免费的，免费的可以用浏览器的开发者工具抓网络请求来分析API，大概也分两种，一种是裸奔的，直接可以用，另一种是加密的，不能直接用，我想的是用PhantomJS抓出cookie之类的再抓最终视频地址，但还没完成。
2. 分段视频预下载。我先实现了下载到本地文件的功能，然后把本地文件路径传给播放器，但这有2个问题是：一、如果下载得比较慢，播放器读完文件播放完后就退出了，二、没有一个适用所有视频的cache值，大了就等待时间长，小了就还没开始播放就结束了。所以我打算再加一个http server给播放器，http server在响应播放器请求时会等下载了再返回数据。

Qt本身没有提供http server的API，在github上搜了搜，确实有一些用Qt实现的repo，我简单看了一下要么太重，要么功能太简单，还有就是只会跑在主线程，我主线程是要有UI的，不能用来serve http的，Qt的类要跑在工作线程还有点tricky，于是放弃了。

我知道Boost.asio有http server的示例，只要把`io_service::run()`跑在工作线程就可以了，代码拷过来了试了试果然可以。只是那个代码还没完全看懂，只看到它打开文件读的操作，没看到它后面继续读继续serve的操作，要再仔细看看。

引入Boost.asio很简单，只要链接Boost.system一个库就行，但在macOS上用Qt Creator直接运行程序会失败，报错：

```
dyld: Symbol not found: __cg_jpeg_resync_to_restart
  Referenced from: /System/Library/Frameworks/ImageIO.framework/Versions/A/ImageIO
  Expected in: /usr/local/lib/libJPEG.dylib
 in /System/Library/Frameworks/ImageIO.framework/Versions/A/ImageIO
```

在网上搜了下遇到这个问题的人还挺多，解决方案却各不相同，有的需要修改系统里的文件，有的需要修改环境变量，都有全局性的影响，不太好。最后偶然发现有人提到macOS从某个版本起（10.12？）就把`/usr/local/lib`这个路径从默认搜索路径里移除了，可我的程序直接从Finder里运行是可以的，就是从Qt Creator里运行出错，于是看Qt Creator的`Projects->Run->Run Environment`里`DYLD_LIBRARY_PATH`和`DYLD_FRAMEWORK_PATH`两个变量里确实都添加了`/usr/local/lib`，把这个路径移除，再运行就正常了。