---
layout: post
image: https://blogimg.minidump.info/2017-01-14-opensource-avege.md
author: missdeer
title: "Avege开源了"
categories: Shareware
description: Avege开源了
tags: OpenSource Go GFW
---

昨天把Avege客户端部分的源代码单独取出来，放到[github](https://github.com/missdeer/avege)上了。然后在v2ex上发了个[帖](https://www.v2ex.com/t/334278)，在twitter上发了条[推](https://twitter.com/missdeerme/status/819721317352017920)，在Telegram上的一些群里发了条消息。终于有了一个[star数过100的repo](https://github.com/missdeer/avege/stargazers)了:P

效果是Twitter上涨了几十个fo，[Telegram群](https://t.me/avege)里多了上百个成员，v2ex上的帖子回复的少，浏览和收藏的多，而对于avege本身，基本处于观望的状态。现在看来确实也有几大硬伤：

1. 依赖redis，让很多人望而却步。
2. 没有文档，连配置文件中各个字段的含义解释都没有。
3. 没有提供编译好的可执行文件，很多没接触过Go的人就很难上手了。

算了，虽说还留了很多坑要填，但我还真没心情去大力推广，爱折腾的人自己折腾吧。