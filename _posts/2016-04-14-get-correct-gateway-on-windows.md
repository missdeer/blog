---
layout: post
author: missdeer
title: "Windows上获取正确的网关信息"
categories: Job
description: Windows上获取正确的网关信息
tags: gateway WinAPI
---
这两天在改一个因为获取网关信息错误而引起的问题。

当初是使用GetIpForwardTable2这个API来获取网关的IP地址，这个API可以同时工作于IPv4和IPv6环境，不过这几天收到问题报告，说客户电脑从一个网络切换到另一个网络时，总是获取到老的网关IP。开始我也觉得很纳闷，今天在我公司的台式机上居然也重现了，即使拔掉网线，还是能查询到之前连接过的网关IP，要在控制面板上把这个网络连接disable掉，才会查询不到，而且我看了一圈，没找到有哪个字段来标识这个信息是否过时。

后来无意间看到GetAdapterAddresses这个API也能获取到网关IP，而且有个状态字段可以判断该adapter是否在用。于是高高兴兴地把这个逻辑换了一套API来实现，测了一下果然能工作。不过这个API在MSDN上的说明提到它会使用大量的系统资源，而且是深入底层网络接口获取数据，所以速度很慢。先不管了，基本功能先保障再说。
