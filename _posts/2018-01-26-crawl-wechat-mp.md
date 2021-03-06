---
layout: post
image: https://img.peapix.com/10641216757862215704_320.jpg
author: missdeer
title: "抓取微信公众号文章"
categories: Coding
description: 抓取微信公众号文章
tags: MITM 
---

一直想要抓取微信公众号文章，目前终于可以一半手动一半自动地抓取指定公众号的所有文章了。

现在主流的大概是两种方法，一种是从搜狗那里抓取，另一种是通过中间人攻击的方式从客户端直接抓取，我是用的第二种，各有优缺点吧。从搜狗抓，需要绕开验证码，而且只能抓最新的10篇文章，有些公众号并没有被收录，等等。从客户端抓取，不小心会被封号，这是最大问题。简单记录一下步骤和注意事项：

- 用OpenSSL生成一个自签名的证书，并导入到客户端所在的系统中，不同系统有不同反应，有些国产Android手机自定义的ROM也许会导入不了，我也不知道怎么办，换个手机是最方便的
- 设置系统代理到自己写的那个抓取程序开的端口，让客户端走代理
- 我的程序是用go写的，用了[goproxy](https://github.com/elazarl/goproxy)这个package，挺简单的，所做的事类似[Fiddler](https://www.telerik.com/download/fiddler)，但没Fiddler功能那么多，也就是简单地观察请求和回复的内容，https的流量则是通过中间人攻击的方式也能解密看到，虽然Fiddler似乎也能写一些代码来扩展功能，但完全自己写的程序可控性更好
- 在微信客户端点开想要抓取的公众号，查看历史消息，这时会有一个`/mp/profile_ext?action=home`的请求，返回是一个HTML文档，拖动页面往下，显示更多历史消息，会有一个`/mp/profile_ext?action=getmsg`的请求，后面有一个参数是`offset=10`之类的，返回一个JSON文档，包含了之后10篇文章的基本信息，比如标题、摘要以及最关键的URL，我就利用这个请求，把参数`offset`改为0开始，http header也照搬，不停地修改`offset`参数，并通过返回信息中的`can_msg_continue`字段判断是否还有文章可被抓取，全部抓完。
- 需要注意在上一步抓取文章信息时每次之间要加入一点延时，我第一次抓没经验，没延时，微信立马就封了我的操作，不能再查看历史消息，过了一段时间才解封。
- 有了文章的URL，就可以通过普通的http请求把文章内容下载下来。注意文章中的插图，全都是`<img data-src="…">`的形式，在浏览器打开文章时，这种图片一开始会通过js先显示一个转圈的图片，等图片加载完毕，才会显示正式的图片，所以当我用`wkhtmltopdf`或`phantomjs`试图将文章打印成PDF格式时，所有图片都只会显示转圈的图。只要把`<img data-src="…">`改成`<img src="…">`即可。
- 另外，为了更保险起见，我从网上找了个proxy池，所有抓文章和文章内图片的操作都是随机选一个proxy走。