---
image: https://blogimg.minidump.info/2019-09-26-change-blog-hosting.md
layout: post
author: missdeer
featured: false
title: "折腾博客"
categories: blog
description: 博客托管在国外导致国内访问速度很糟糕
tags: blog
---

## 关于托管

因为用的是`Jekyll`，所以之前把博客放在github pages上，觉得很省事，而且由于无论是家里还是公司的网络都对海外线路比较友好，所以一直以为博客访问速度不算慢。前些天由于家里的路由器一时半会点不亮，没了全局的科学上网，才发现魔都电信直连github pages的速度已经慢得完全无法忍受。怪不得以前看到一些纯技术的群里有人问怎么从github下载代码快一点，我还觉得有点诧异，因为我觉得并不慢呀。

现在自己有了体会，觉得不能放在github pages了事。鉴于前一段时间用linode东京2的VPS科学上网速度不慢，于是把博客迁移过去了。迁移还需要多做一点事情，包括：

- 在github上设置webhook，每有push就自动在VPS上pull一下
- 在VPS上装`jekyll`，pull完了得自己`jekyll build`，而这些事github pages完全不需要人工介入
- 修改dns设置，指向VPS
- 修改VPS上的web server配置，我用了[Caddy](
)，这东东相比[nginx](https://nginx.org/) 能省一些事，比如自动更新[Let's Encrypt](https://letsencrypt.org/) 的证书，自动处理github的webhook等等

干完这些事，我就安心地放任不管了。结果几天后，偶然看了一眼[Google Analytics](https://analytics.google.com) 的数据，发现访问量骤跌，虽然原本也不多，一天20多个IP，现在变成不到5个！这可真是个糟糕的结果。

结论是linode东京2的线路并不好，科学上网速度快大概是因为协议的缘故。

于是我又只好套上[Cloudflare](https://www.cloudflare.com/) 的CDN，虽然仍然有不少地区会访问不了，但是比直连linode东京2好不少了。

## 关于内容

一直以来把博客当日记用，所以虽然这么多年来积累了不少的篇数，但对其他人来说并没有多少营养价值。反倒是自己偶尔看到多年前写的东西，能把自己感动哭。

现在想想，一方面是由于自己总是折腾些比较小众的东西，并没有多少人会感兴趣，另一方面自己在本职或擅长的方面也并不突出，所以写不出有深度有内涵或让人眼前一亮或让人沉浸回味的东西来。

感觉这是很难改变的状况了，只能继续保持现状了。

## 关于折腾

很多人（包括我）在做一些事情的时候，往往会对事情本身并不特别关注或感兴趣，反而对事情相关的一些周边事物表现出极大的兴趣并投入相当多的时间和精力，甚至超出原本的事情本身。这就是所谓的“本末倒置”。

比如：

- 听音乐喜欢折腾音响，甚至关注用的是水电还是火电
- 摄影喜欢折腾相机和镜头
- 下棋喜欢摆送棋盘和棋子
- 用个软件喜欢换皮肤，甚至自己制作各种主题

等等。

而我这里写个博客，产出内容的质量不管，托管换了几处，程序也换过几次，主题也换过几次。最近把主题换成[Mediumish](https://github.com/wowthemesnet/mediumish-theme-jekyll/) ，首页可以为每篇文章加一张展示图片，我就觉得很酷很炫。于是先手动给文章内有图片的文章都加了图片，这两天突然觉得Bing每天发的用于做桌布的图片很养眼，直接拿来给每篇文章加个图片不是刚刚好吗！于是写了个小程序，接受一个http请求，根据请求中附带的路径，先查看一下这个路径的文章内容，如果文章中自己就有一张不小的图片，便返回这个图片，不然则从Bing那里随机选一张图片返回。

所以，不务正业的人，总归能找到不务正业的事做。