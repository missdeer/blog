---
layout: post
author: missdeer
title: "升级istkani"
categories: Shareware
description: 升级istkani
tags: Shareware istkani
---
昨天打算提交一个istkani的新版本到app store，其实没什么更新的内容，前段时间在UI上微微调整了一下，其他原本想加的功能一直由于拖延症而没动手。只是因为iOS8发布了，Xcode也升级到了6.0.1而想试一下。结果遇到了不少问题。

Qt5.3.2也在前些天刚好正式发布，于是用于编译新版本。没有QtQuickCompiler的QtQuick应用感觉就是慢，不过Qt的售价也实在让人承受不起，暂时忍了！用Xcode6打开工程后，可以正常编译部署，不过到了发布那一步就傻眼了。Organizer那里没有找到原来的Distribute按钮，不知道该怎么导出ipa文件了，在网上搜了一下可以用xcodebuild命令行导出。然后从Xcode里打开Application Loader，发现3.0版本不像以前的能自动列出所有登记的app，于是只好从官网又下了一个2.9版本。发现iTunes Connect也改版了，主要是加了4.7和5.5两种屏幕的截图上传，以及新增的视频上传功能，摸索着再参考网上的文章也勉强能用。用Application Loader上传app时一直卡在Authoricating啥的那一步，从stackoverflow的一张帖子里看到只要把Application Loader中的网络配置文件改一下，把proxyPort改到80就可以了，确实一下就传上去了。

如此经历再一次证明苹果就是一群美工在写代码！
