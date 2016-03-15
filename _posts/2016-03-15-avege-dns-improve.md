---
layout: post
title: "改进avege的dns解析功能"
categories: Shareware
description: 改进avege的dns解析功能
tags: avege dns
---
原本avege就是有一个解决dns污染的方案的，是参照ChinaDNS的原理写的，简单说来就是同时请求国内和国外的DNS server，当收到结果的IP被认为是国外时，丢弃国内DNS server的结果，只取国外DNS server的结果，不然就取国内DNS server的结果。这是基于一些基本的假设，比如总是国内DNS server先返回结果，比如GFW不会使用国内IP来污染。

本来从原理上看，只要假设成立，那么这个方案也应该是能正常工作的。但我泱泱天朝的网络状况怎么可能这么简单地假设，所以我在实际使用过程中发现，解析twitter的域名总是返回一个印尼的IP，而这IP似乎并不是twitter的！

忍了一段时间，实在心里不舒服，还是改改吧，基于名单的方案又简单又可靠。网上可以找到[gfwlist](https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt)，可做黑名单，有[accelerated domain china list](https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf)，可做白名单，还有可做block list的[hosts](https://raw.githubusercontent.com/vokins/simpleu/master/hosts)。