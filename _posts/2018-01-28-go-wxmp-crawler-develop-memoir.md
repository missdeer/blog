---
layout: post
image: https://img.peapix.com/3246365363829883648_320.jpg
author: missdeer
title: "Go微信公众号爬虫踩坑实录"
categories: Coding
description: Go语言开发微信公众号爬虫踩坑实录
tags: Go
---

用Go开发微信公众号爬虫，踩到一些坑，记录如下。

- 爬虫必然会开启大量[http.Client](https://golang.org/pkg/net/http/#Client)去抓取内容，于是使用[sync.Pool](https://golang.org/pkg/sync/#Pool)来管理这些[http.Client](https://golang.org/pkg/net/http/#Client)，但是马上就会遇到[sync.Pool](https://golang.org/pkg/sync/#Pool)返回一个nil出来，尝试换成自己写一个简单的Pool实现，仍然有相同问题，后来才发现原来在下面把变量改成nil然后放回pool去了。
- 文章主体的HTML文本下载是很快的，内嵌的图片资源下载很花时间，尤其是有些文章会内嵌很多图片，所以要把下载HTML和下载图片的semaphore并发量按比例调整。比如说平均观察下来一个HTML内有10个图片资源，那么假设下载HTML的semaphore设成15个并发量，下载图片的semaphore则设成150个并发量。
- 看情况调整[http.Client](https://golang.org/pkg/net/http/#Client)的各个参数，比如Timeout，可以根据当前的网络情况和下载内容长度来设置，以提高[http.Client](https://golang.org/pkg/net/http/#Client)的快速响应能力。
- 在mac上运行时很快就遇到了进程打开fd数量限制，看了一下mac上才256，Linux桌面版或没调整过的服务器版默认可能是1024，确实很容易碰到，用lsof看了一下，原来是很多socket都打开着。[http.Client](https://golang.org/pkg/net/http/#Client)得到response后，官方示例都是`defer resp.Body.Close()`在作用域退出时关闭，其实可以在读出response所有内容后立即关闭，但这并不能解决问题。后来发现是keep alive特性导致的，把[http.Transport](https://golang.org/pkg/net/http/#Transport)中的`DisableKeepAlives`设置成`true`即可。
- [sync.WaitGroup](https://golang.org/pkg/sync/#WaitGroup)的记数器要尽早设置，以免还没来得及设置，Wait()就返回了。
- 我用[PhantomJS](http://phantomjs.org/)把抓下来的HTML文档转换为PDF格式，另一个方案是[wkhtmltopdf](https://wkhtmltopdf.org/)，前者有更高的保真度，更多的可控性，但更慢更占内存，胜在最终效果好。
- [PhantomJS](http://phantomjs.org/)对本地路径的字符编码比较挑剔，比如在Windows上有中文字符的路径就不能正常工作，我的解决办法是找了个汉字转拼音的[package](https://github.com/mozillazg/go-pinyin)，但这个[package](https://github.com/mozillazg/go-pinyin)并不处理非中文的字符，所以要自己写些代码处理全英文或中英文混合的情况。
- 之前我的实现是先把所有HTML和图片下载完，再一个个全部转换成PDF，这样很浪费时间，后来改成下载完一个HTML和它包含的所有图片资源就将其转换为PDF。