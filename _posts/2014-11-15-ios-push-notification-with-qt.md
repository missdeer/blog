---
layout: post
title: "使用Qt实现iOS push notification"
categories: Coding
description: 使用Qt实现iOS push notification
tags: qt iOS push
---
先看一遍Apple的[官方文档](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Introduction.html)或者网上随便找个入门介绍文章，知道代码主要要做的是在AppDelegate里开头做点初始化工作，然后实现几个函数。Qt对各个平台底层都做了良好的抽象和封装，好在有人做过些[相关的研究](https://github.com/colede/qt-app-delegate)，可以自己写个AppDelegate替换掉原来的那个。那块代码抄过来后，要注意的是因为我们替换原有的AppDelegate已经过了didFinishLaunchingWithOptions的时机，所以我们在自己的AppDelegate里写一些初始化的代码在didFinishLaunchingWithOptions里是没用的，我的办法是在替换AppDelegate后再做那些初始化工作。但是另外带来些问题，原来写在didFinishLaunchingWithOptions里的一些代码是可以work的，写到其他地方时可能就直接crash了，比如以下这些代码：

```objc
[application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
    UIUserNotificationTypeAlert
    | UIUserNotificationTypeBadge
    | UIUserNotificationTypeSound
    categories:nil];
[application registerUserNotificationSettings:settings];
[application registerForRemoteNotifications];
```

我也没想明白为什么，只好不用这些东西。

有了自定义的AppDelegate，剩下的跟网上众多iOS Push Notification的简介文章基本一样了。不过折腾证书真是要纠结死我了。
