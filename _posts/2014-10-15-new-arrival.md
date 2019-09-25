---
layout: post
image: https://blogimg.minidump.info/2014-10-15-new-arrival.md
author: missdeer
title: "新品上架"
categories: Startup
description: 妹子们的淘宝店新品上架
tags: shop taobao
---
已经过去大半个月了，十一前婷婷发来一堆图片，十几个zip包总共大概有10来GB，整个十一我就全用来上架到店铺去了。上半年妹子开了个淘宝店，从[http://shop109252741.taobao.com/](http://shop109252741.taobao.com/)或[http://shop.yii.li/](http://shop.yii.li/)访问，长长半年也就卖掉两件衣服，哈哈。婷婷上个月说有一批秋装，可以拿来上架，于是妹子跑去西安游山玩水了，我就苦逼地在家上货。那个MacBookAir也着实不好用，主要是屏幕太小，软件缺少，以及淘宝后台网页不好用。但是事实证明，节后我回到上海用台式机上的Windows，也好用不了多少，阿里做的软件真烂啊，淘宝助理经常崩溃，经常不能上传，经常刷不出图片空间。

整个十一假期加后面一两天晚上，总共才上了94件衣服上去，然后用手机打开一看，居然手机版的信息必须再单独上传。于是花了两天，其实总共大概只用了几个小时，用Go语言写了个小程序，源代码放在[github](https://github.com/missdeer/TaobaoMobileImageResizer)上了，可以到[gobuild.io](http://gobuild.io/github.com/missdeer/TaobaoMobileImageResizer)下载，这gobuild服务可能有bug，有几次下载到的压缩包里面的可执行文件是0字节的，自动把所有的大图片切小，再缩小到620*960以下分辨率，昨天晚上终于把所有的手机版信息都上传了。顺便感叹一下Go的开发效率，终于让我这个基本只会C++的人体验到了脚本语言开发效率的感觉。

还有大概一半的衣服没上架，慢慢弄吧。可是我苦恼的是，怎么刷销量啊，呜呜！
