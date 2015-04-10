---
layout: post
title: "Amazon S3和ElastiCache的传输性能"
categories: Job
description: 用Amazon EC2连接Amazon S3和ElastiCache的传输性能
tags: Amazon EC2 S3 ElastiCache
---
今天简单地测试了一下Amazon EC2连接Amazon S3和ElastiCache的传输性能，记下以作备忘。EC2、S3、ElastiCache都选的是Tokyo机房的。其中S3是通过[这个库](https://github.com/mitchellh/goamz)做的，ElastiCache其实就是memcache，是用[这个库](https://github.com/bradfitz/gomemcache)做的。

S3上传2.5KB的小文件，耗时大体在50~100ms，目测70~90ms居多。下载2.5KB大小的文件，耗时大体在20~70ms，目测30~50ms居多。

ElastiCache读写2.5KB数据，均在2.5ms左右。我在一台2GB RAM/2.6GHz Core Duo CPU的机器上用twemproxy在本机做了个代理连接千兆局域网内的其他memcached，写入操作在700+µs。

这个测试非常粗糙，仅供有限的参考。
