---
layout: post
title: "dev2kindle WIP(1)"
categories: Coding
description: dev2kindle开发进度
tags: Kindle RSS
---
一直以来说微信公众号的阅读体验不满意，但是现在越来越多的高质量的文章都发到微信公众号上去了，再加上之前Google Reader关闭，这让我几乎放弃了之前每天坚持阅读高质量文章的习惯。

前些天又翻出吃灰很久的Kindle 4和Kindle DXG，心中微微遗憾。后来想想，可以写个小程序，把一些文章抓下来发到Kindle上阅读！说干就干，代码就放在[github](https://github.com/dfordsoft/dev2kindle)上了，为什么叫这个名字呢，因为我抓的都是开发相关的内容。

目前的做法是先从那些网站上抓出文章链接，然后添加到Instapaper，最后如果达到50篇了，就让Instapaper把文章推送到Kindle。这样做唯一的好处是自己少写点代码，但缺点也很明显：

1. Instapaper抓不出某些链接的内容
2. Instapaper抓出链接的内容并不能很好地去除无用信息
3. Instapaper一次最多只能推送50篇文章

所以之后想做的是：

1. 去除对Instapaper的依赖，使用自己的Readability实现，或者第三方可靠的服务也行，比如这家[URL2io](http://www.url2io.com/docs)。
2. 然后自己生成Kindle可用的.mobi文件，这点要仔细考虑一下，如果用Amazon官方的Kindlegen工具，就不能在树莓派上用，不知道Calibra行不行。

最后是可能会做，但工作量估计很大的：

1. 做成像Google Reader那样的Web UI
2. 自己搞一个可靠的微信公众号抓虫，现在用[微广场](http://iwgc.cn)的源数据不多。搜狗有很强大的反爬虫机制，而且数据据说也不全，只有另想办法。