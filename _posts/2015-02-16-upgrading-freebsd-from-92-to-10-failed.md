---
layout: post
title: "升级FreeBSD从9.2到10.0失败"
categories: os
description: 升级FreeBSD从9.2到10.0部分失败
tags: FreeBSD
---
昨天想在装在T43上的FreeBSD上编译些软件，结果不是缺这个库就是那个so版本号不对，应该都是上次试图将9.2升级到10.0失败后rollback造成的。我就觉得现在这系统虽然能运行，但连个程序都编译不了，那跟废了有什么区别啊，果断再次试图升级。

从网上搜了一篇升级教程，使用`freebsd-update`命令，还是比较简单的几个步骤：

```shell
freebsd-update fetch install
freebsd-update upgrade -r 10.0-RELEASE
freebsd-update install
shutdown -r now
freebsd-update install
...
freebsd-update install
shutdown -r now
```

基本上就是这么些步骤，但就是`...`的地方，说是要重新编译一下一些程序，比如从port装的那些，但是我压根不知道哪些程序需要重新编译，我也不记得哪些程序是从port安装的，我只知道在port里编译openssl都不成功。我用portsnap更新了port树，仍然编译不了openssl，而其他一些程序编译时总是报找不到libcrypto.so的哪个文件，或者libssl.so的哪个文件。

这样操作了一遍后，LXDE也进不去了，大概是某个依赖的库版本不对或干脆缺了吧。

想了想，FreeBSD这种系统做日常的桌面系统果然还是比较折腾人的，我决定还是过完年去买个新创云那种小主机来装BSD好了，也不需要GUI，只要能SSH连上去，让它提供网络和存储等服务就行了。这个T43就装个Fedora好了，另一个本装了Debian，Debian虽然稳定，但它的软件往往比较老，有些时候还是比较烦人的，装个Fedora尝试了一下比较新的软件，虽说Arch会更快，但那个我实在有点承受不起，太容易升挂了。

就这样吧。
