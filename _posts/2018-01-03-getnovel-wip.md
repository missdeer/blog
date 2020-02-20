---
layout: post
image: https://img.peapix.com/454934669095088549_320.jpg
author: missdeer
title: "抓取网络小说到Kindle更新"
categories: Shareware
description: 抓取网络小说到Kindle更新
tags: Kindle
---

抓取网络小说的小程序断断续续有了不少更新，除了支持更多的小说网站外，还有一些值得一提的内容：

- 程序结构更加紧凑灵活，新增或删除支持的小说网站只需要直接增加源代码文件或删除对应的源代码文件即可，不需要修改原有的代码。
- 新增了支持直接生成epub和pdf格式，其中默认的pdf排版针对Kindle DXG做了适配，包括版面大小，边框大小，字体名和字体大小，行间距等，全部都是往在DXG上看最舒服的方向上靠拢。
- 增加了并发下载的功能，默认以10个并发量下载，然后通过channel把下载的内容传给一个goroutine，再排序，最后生成文件。似乎select一个channel时，channel容量小的会比容量大的快，大概是遍历channel耗时更久？
- 因为Kindle在打开大PDF文件时很慢，所以增加了将一个大PDF拆分成几个小PDF文件的功能。
- 增加了GNU风格的命令行参数，感觉好极了。