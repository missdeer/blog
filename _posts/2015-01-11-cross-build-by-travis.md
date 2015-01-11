---
layout: post
title: 使用Travis服务交叉编译Go程序
categories: coding
description: 使用Travis服务交叉编译Go程序
tags: travis golang
published: true
---

昨天花了一天时间，把github上几个Go程序通过travis实现交叉编译，再把编译生成的二进制可执行文件push回github上的prebuilt branch，这样每次有新的commit后，都会自动生成各个支持平台的最新的二进制可执行文件，相当方便。

可以看看以下几个repo，README上就列出了所有二进制可执行文件的下载链接：

- [toto](https://github.com/missdeer/toto)
- [TaobaoMobileImageResizer](https://github.com/missdeer/TaobaoMobileImageResizer)
- [ifconfig](https://github.com/missdeer/ifconfig)
- [KellyBackend](https://github.com/missdeer/KellyBackend)
- [KellyWechat](https://github.com/missdeer/KellyWechat)
- [MiaoCoffee](https://github.com/missdeer/MiaoCoffee)
- [ReadabilityProxy](https://github.com/missdeer/ReadabilityProxy)

有这个念头还是因为看到两个github上的项目引起的。一个是[Gobuild.io](https://github.com/gobuild/gobuild3)，它提供了Go程序的自动编译和下载服务，另一个是[rapidjson](https://github.com/miloyip/rapidjson)，它实现了自动生成文档并通过github pages显示的功能。于是我就想到可以把这两个功能合并起来。

实现这么个功能需要以下步骤：

- 添加repo的travis支持，并且设置成只有.travis.yml文件存在时才触发，这样可以避免自动push到其他branch时被触发build进入死循环。
- travis本身可以设置多种不同Go版本实现持续构建，但这里我只需要随便选一种就行了。关键是我会再调用一个自己的shell 脚本实现交叉编译。
- 自己的shell脚本自动从[golang.org](https://golang.org/dl/)下载最新的Linux amd64的Go工具链包，再参考[这篇文件](http://dave.cheney.net/2013/07/09/an-introduction-to-cross-compilation-with-go-1-1)生成交叉编译工具链，然后为自己的Go程序交叉编译，最后push回github。
- 要push回github，需要在github的setting页面得到一个github token，把这个40个字符长度的字符串填到travis的项目setting的environment variable中去，名字定为GH_TOKEN。也可以直接用travis encryt命令（需要`gem install travis`先）生成一个加密后的字符串直接写到.travis.yml中，但这种方法有时候travis并不能每次都正确读到，不知道什么原因。
- 最后一点要注意的是，生成的二进制文件不要push到master branch，因为会死循环触发travis，所以要另外建个空branch，可以用`git checkout --orphan prebuilt`和`git rm --cache -r .`命令创建一个名为prebuilt的空branch，再随便添加个空文件`touch README.md`，`git add README.md`，`git ci -m "(+)add README"`，就可以push到github去了`git push origin prebuilt`。

其实吧，这只是一种穷人的占便宜山寨做法，有条件的人当然是上专业的CI服务啦，专业提供CI服务的商家就有不少，比如travis就是，也可以自建Jenkins。当然玩票性质的就这么折腾一下算了！

