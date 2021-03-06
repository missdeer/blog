---
layout: post
image: https://img.peapix.com/14387568248246379564_320.jpg
author: missdeer
title: "Go微信公众号爬虫踩坑实录（二）"
categories: Coding
description: Go微信公众号爬虫踩坑实录
tags: Go
---

过去一周仍然花了些时间更新微信公众号爬虫，又踩到些坑，记录一下。

- 之前是用semaphore来控制并发下载的goroutine数，后来发现这种方法看起来比较粗放，于是改成固定数量的goroutine池，比如固定30或50个goroutine一直跑着只用于下载HTML，固定15个goroutine一直跑着只用于将HTML转换为PDF，前一种goroutine下载完一个HTML后通过channel告诉后一种goroutine开始转换，感觉好多了。
- 微信公众号文章中常常包含大量的图片，而且不少公众号经过几年的经营，已经发过多达几千的文章，将所有这些文章全部转换为PDF的话，PDF文件的体积可以达到2GB甚至更多，这么大体积的PDF对阅读器来说是一大考验，虽然PDF的保真度很好，但是在kindle之类没有彩色的阅读器上并没多少用处，所以能生成mobi格式是更好的选择。
- 爬下来的微信公众号文章HTML里有大量无用的HTML/JS/CSS内容，对于kindlegen来说完全无用，所以只需要保留正文`<p></p>`之间的内容即可。
- kindle的HTML渲染程序对HTML tag的支持极其有限，所以将多余的各种`style`等等attribute删除掉即可。
- 并不是所有的GIF都能提取出多个frame，大概是因为不是动画的缘故？我不确定，这种情况就直接保存即可。
- 某些GIF格式图片的存在会引起kindlegen程序crash，我没找出来具体规律，把所有GIF格式全部转换成JPG格式即可。
- 有些文章被屏蔽了，但仍然会在目录中存在，只有在爬取正文内容时才会返回一个错误信息，而且错误信息分好几种，需要统一处理这些情况。
- 虽然我每次请求都加入了1~5秒不等的延时，但可能仍然过于频繁，周末调试程序时微信就把我的账号封了查看公众号所有历史消息的功能，直到2天后才恢复，大概需要加入更长时间的延迟才行。
- mobi文件的封面是一张图片，要在图片上用指定的字体写字可以使用`github.com/golang/freetype/truetype`包，虽然只支持`ttf`格式的字体，但也足够了。

