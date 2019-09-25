---
layout: post
image: https://blogimg.minidump.info/2016-03-23-cant-pass-app-store-review.md
author: missdeer
title: "进球啦app提交app store审核不通过"
categories: Shareware
description: 进球啦app提交app store审核不通过
tags: iOS app review jinqiula bearkani-lite
---
之前在做的滚球推荐app只能在Android上分发，后来想想还是咬咬牙提交到Apple App Store试试，不过还是做好了被拒的心理准备的，因为照以前的经验，这个App有两个可能的原因很明显会被拒，一个是功能太简单，基本上只是浏览一个表格而已，另一个则是用户付费的功能，因为Android系统在国内收费不易的情况下，我就一直懒得做，只是放了个页面说明，让用户加我们的QQ/微信来通过微信或支付宝等国内流行的移动支付方式来收费。

果不其然，在折腾了几天开发和发布证书，好不容易提交审核一周后，进入review状态仅仅3个小时，就被拒绝了，原因就是这付费功能被要求使用In-App Purchase来实现。

网上翻了一些资料来看，iOS的IAP功能实现起来略显繁琐但并不复杂，app是用Qt写的，本来Qt企业版是提供一个addon来实现IAP的，我用开源版的还以为Qt 5.6已经带了这个addon呢，在安装路径里没找到，不过在网上找到了它的git仓库，看来得自己拼拼凑凑抄抄改改搞定了。
