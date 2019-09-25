---
layout: post
image: https://blogimg.minidump.info/2016-03-18-dns-modification-caused-nexus-cant-connect-to-wifi.md
author: missdeer
title: "修改DNS导致Nexus手机连不上WIFI"
categories: Mobile
description: 修改DNS导致Nexus手机连不上WIFI
tags: DNS Nexus Mobile WIFI
---
之前给avege的DNS解析功能加了黑名单白名单，然后就直接部署在家里的树莓派上了，昨天晚上突然发现妹子的Nexus 5和我的Nexus 6全都连不上WIFI了，右上角的WIFI图标一直显示着感叹号。换热点，重启路由器，重启手机WIFI开头都没有，我想了想这两天来做的事情，基本确定是因为avege的DNS解析功能导致的。

我查了一下被屏蔽列表，确实有几个Google的域名，然后把它们全部删掉，果然就正常了。

今天我又查了一下源头，网上有[文章](https://www.noisyfox.cn/45.html)说，Android官方ROM会尝试连接[clients3.google.com/generate_204](http://clients3.google.com/generate_204)这个网址，如果连接不上，就会显示感叹号。众所周知，Google的绝大多数域名在大陆是被墙的，所以Nexus 5/6这些手机买来后都会显示个感叹号，我根据网上的说法，把那个网址换成没被墙的[www.google-analytics.com/generate_204](http://www.google-analytics.com/generate_204)后，感叹号就消失了。而这次www.google-analytics.com这个域名就在被屏蔽的列表里面，所以就又连不上了。至于为什么现在因为这个网址连不上直接导致连WIFI也不能连了，这个问题我也没想明白，以前即使有感叹号也是能连WIFI的。
