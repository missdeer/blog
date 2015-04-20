---
layout: post
title: "生成iOS Push Notification证书"
categories: coding
description: 生成iOS Push Notification证书
tags: iOS PushNotification certificate
---
昨天又折腾了大半天iOS Push Notification的证书，之前也折腾过一次，真是麻烦，网上的文章大多步骤相似却不能只靠文章中的步骤得到能用的证书。这里暂且记一下。

- 在本机Keychain Access里点`Application菜单`-`Certificate Assistant`-`Request a Certificate From a Certificate Authority...`，填入app名字（假设为myapp），生成.ertSigningRequest文件保存到硬盘；
- 在Keychain Access的Login分类中搜索上一步填入的app名字（已设为myapp），选private key导出p12文件保存到硬盘，得到myapp.p12；
- 上developer.apple.com网站，添加一个具体的app bundle id，并生成一个privision，下载后导入Xcode；
- 在网站上为新加的app bundle id添加一个包含push notification功能的证书，下载保存为aps_developement.cer之类的名字；
- 命令`openssl x509 -in aps_development.cer -inform der -out aps_development.pem`，转换一下证书格式到PEM格式；
- 命令`openssl pkcs12 -nocerts -in myapp.p12 -out myapp.pem`，会强行要求设置passphrase，下面会再用其他命令移除；
- 命令`openssl rsa -in myapp.pem -out myapp-noenc.pem`，把之前步骤中生成的PEM移除passphrase；
- 命令`cat aps_development.pem myapp-noenc.pem > key.pem`，把证书和私钥合并到一个文件里；
- 这样得到aps_development.pem和key.pem两个文件就可以用于向Apple服务器发送Push Notification了。