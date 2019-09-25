---
layout: post
image: https://blogimg.minidump.info/2014-10-30-deploy-go-applications-on-sohu-paas.md
author: missdeer
title: "部署Go程序到搜狐云景PaaS"
categories: Go
description: 部署Go程序到搜狐云景PaaS
tags: coding Cloud Go
---
之前注册了搜狐云景PaaS，被送了100元的券，不过当时看了一下发现不支付Go程序，于是就没玩下去了。前几天连续收到几封邮件，说钱要花完了，也没放在心上，觉得反正玩不了，就随它去吧。今天在v2ex上看到有人说可以免费送3个月的使用配额，于是又上后台看了一下，发现它居然使用限制那么少，可以自己在配置文件中指定要运行的程序路径，这样就可以部署Go程序了，立马把之前在京东云上部署的[ifconfig](http://ifconfig.jd-app.com)在搜狐云景上也部署了[一个](http://ifconfig.sohuapps.com)，感觉还不错。

然后我就想到一个问题，以搜狐云景的定价，我觉得还是比较高的，免费的不算，最低配一个月也要60多元，一年就得700多元吧，这个价格可以在阿里云上买个VPS了，感觉VPS比PaaS可用性好多了，那为什么要花更高的价格去买PaaS来用呢，就为了减少系统维护成本吗？这个问题真要好好考虑一下。
