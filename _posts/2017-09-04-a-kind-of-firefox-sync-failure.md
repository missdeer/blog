---
layout: post
author: missdeer
title: "一种Firefox同步失败的情况"
categories: Software
description: 一种Firefox同步失败的情况
tags: Firefox
---

前些天突然发现家里台式机（Windows 10）上的Firefox不能工作了，具体表现是：

* 同步不正常
* 某些https网页打不开
* 重装后变本加厉，所有https网页都打不开了，同步账户也登录不进了（因为会跳转到一个https页面）

无论我如何删光Firefox的数据，如何重装Firefox，装不同版本的Firefox都是同样的现象，就差重装系统了（估计重装系统都没用）。

本来也怀疑过是家里网络的原因，但是另一个装了32位Windows 10的平板上的Firefox却是工作得好好的样子，所以也觉得跟网络的关系不大。

昨天又开始折腾，偶然想到Firefox只是SSL证书握手失败，想来还是网络的缘故。于是拿出联通日租卡MIFI，把台式机上的有线网络（电信）禁用，走MIFI，果然一切都正常了。

究其原因，我家里的网络在路由器上屏蔽了一系列的域名，估计是把一些Firefox或SSL证书验证相关的域名屏蔽掉了，具体是哪些域名就不清楚了。