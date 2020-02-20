---
layout: post
image: https://img.peapix.com/14153525647846356017_320.jpg
author: missdeer
title: "Go语言操作Amazon S3"
categories: Job
description: Go语言操作Amazon S3
tags: Go Amazon S3
---
之前提到的Thumbnail Service是用准备用Amazon S3来存储的，因为图省事，网管找了个[s3fs](https://github.com/s3fs-fuse/s3fs-fuse)把S3 bucket直接mount到本地，于是就当成本地目录一样读写。今天网管突然提到S3连接并发和性能的问题，找了篇[文章](http://www.cyclecomputing.com/blog/aws-s3-performance-tip-using-dataman-to-increase-concurrency-leads-to-500-mbps-upload-speed/)看了看，大概意思是并发过多或过少性能都不好（废话）！

于是就想不用s3fs了，直接用Amazon的API来操作吧，然后随手搜了一下Go语言的S3库，找到一个这两天还有commit的[库](https://github.com/mitchellh/goamz)，而且README里自己也说目录有heavily used，果断试试。

然后写了点代码简单测试了一下，发现如果同时有1000个PUT请求的话，大概有200多个会出错，诡异的是错误消息居然是什么TLS握手失败，难道是客户端这边同时进行1000个连接的SSL计算然后吃不消了？不清楚了。再试了下同时500个PUT请求，跑了几次都没问题。想到我的服务器是预计是同时有1000-2000个客户端连接，每个客户端连接上传一个文件我就会有一个PUT请求，如果不是这次预先测试的话，可能同时就有1000-2000个PUT请求这种跑法了。而且还有除了PUT也有GET请求会很频繁，看来得再想想实现个“请求池”之类的东西，也就是限制一下同时发出请求的数量。
