---
layout: post
image: https://fastly.jsdelivr.net/gh/missdeer/blog@master/media/2019-09-17/mainwindow1.png
author: missdeer
featured: false
title: "为了舒服地写微信公众号，我写了个文章编辑器"
categories: Shareware
description: 为了能舒服地在微信公众号上写文章，我特地写了个基于Markdown的编辑器
tags: Markdown
---

前段时间突然心血来潮开通了一个[微信公众号](../../08/new-wechat-mp/)，虽然至今为止也才写了十几篇文章，但是用了官方文章编辑器和一票第三方文章编辑器后，我决定自己写一个。

于是我罗列了几条必需的需求：

- 基于Markdown，写技术文够方便简单
- 能保存/读取文档，可以随时中断/继续写作
- 能自定义输出样式，满足我时不时想换种审美的需求
- 能方便地输出可以保持样式地粘贴到微信公众号后台文章编辑器的格式

然后就可以动手了：

- 用Qt写一个桌面应用，这是我最擅长的领域，其实如果技术上可行，可能一个web应用更合适。不过用Qt写了不排除后面可以通过WebAssembly打包成Web应用的可能。
- 通过cgo调用Go写的Markdown渲染引擎，简单调研下来发现两个完成度比较高的开源项目：[Goldmark](08/new-wechat-mp/) 和[Lute](08/new-wechat-mp/) ，都支持通过[Chroma](https://github.com/alecthomas/chroma) 实现代码高亮渲染。
- 通过[Qt WebChannel](https://doc.qt.io/qt-5/qtwebchannel-index.html) 实现渲染结果预览，这种技术可以达到一种比较平滑的效果，用户体验较好。
- 输出微信公众号后台文章编辑器可用的样式，关键的技术是将渲染结果以HTML格式放入系统剪贴板，而为了HTML文档能保持完整的样式，需要把CSS都嵌入HTML的`style`属性中。

总的说来，这个编辑器并没有使用高深的技术，而是几种简单技术的拼凑。关键是细节上还有不少需要仔细调整的会极大地影响到使用体验。

一些界面截图：
主窗口1
![主窗口1](https://fastly.jsdelivr.net/gh/missdeer/blog@master/media/2019-09-17/mainwindow1.png)
主窗口2
![主窗口2](https://fastly.jsdelivr.net/gh/missdeer/blog@master/media/2019-09-17/mainwindow2.png)
主窗口3
![主窗口3](https://fastly.jsdelivr.net/gh/missdeer/blog@master/media/2019-09-17/mainwindow3.png)
偏好设置
![偏好设置](https://fastly.jsdelivr.net/gh/missdeer/blog@master/media/2019-09-17/preference.png)