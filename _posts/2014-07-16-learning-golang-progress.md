---
layout: post
title: "Go语言学习进展"
categories: Coding
description: 已经能用Go语言写小程序了
tags: Go
---
学Go语言已经有一段时间了，其实之前就一直在改[Yiili](http://yii.li)就是用Go语言写的，但毕竟只是在别人已经比较完整的程序上修修补补而已。从周日开始总共花了近3天时间，把公司那个项目的消息转发服务器用Go语言实现了。主要还是不够熟练，很多基本的东西仍然要不停地翻说明文档和在网上查解决方案，所以比较慢，相信熟练起来后这个时间可以大大缩短。这个服务器只是个RESTful API服务器，功能也非常简单，包含了操作数据库和memcached，代码量总共才几百行，真爽快，如果用C++实现肯定不止这么点。

饭店那个项目的服务器部分我也打算用Go实现，为了能尽快实现，就用beego框架吧。本来对beego的易用性还是很赞赏的，不过前些天看到v2ex上[一个帖子](http://www.v2ex.com/t/89374)，有人把beego的[一些源代码](https://github.com/astaxie/beego/blob/cec151fda71cf6220fcfc9487240989d6dee1f6e/orm/db.go#L801)翻出来，确实实现得很丑，导致我现在对beego的好感度急剧下降，已经在考虑换[Revel](https://github.com/revel/revel)或[Martini](https://github.com/go-martini/martini)做其他新项目了。其实用Go语言实现的Web框架现在已经有很多了，但目前仍然在活跃开发，而且质量上也已经有项目得到验证的，大概也不多吧，据beego的作者说beego现在已经被各大公司用于开发内部系统，质量基本上得到了验证，其他Web开发框架也没相关数据，所以饭店项目为稳定起见，还是用beego吧。
