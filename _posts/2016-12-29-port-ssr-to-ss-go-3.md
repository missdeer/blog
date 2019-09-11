---
layout: post
author: missdeer
title: "SSR混淆协议Go版移植手记（三）"
categories: Shareware
description: 完成http_simple/http_post/random_head混淆插件
tags: Go GFW shadowsocks
---

本来实现了tls1.2_ticket_auth混淆方法后，我觉得够用了，便想直接去做auth_sha1_v4协议了，但是调试了两天，没调通，很沮丧，还觉得没什么头绪。至少在调试混淆方法时，我用[C#](https://github.com/shadowsocksr/shadowsocksr-csharp/releases)版做对比，通过抓包可以明确比较我的程序混淆结果是否正确，但协议就要麻烦些，协议是将加密前的数据预处理一遍，很难对比我的程序是否处理正确了。

于是我就转移目标，把其余的几个混淆方法也做了，包括http_simple、http_post和random_head。前两种的方法很相似，encode都是在加密数据的头部加一个HTTP请求的头，区别是一个是加GET，另一个是加POST头。然后把加密数据最开始的部分（一般是ss协议头，包括地址类型，地址和长度）转成16进制的字符串加到HTTP头的路径中，我因为这步转换出了差错，折腾了近一天才发现，原本我一直把数据当成URL percent encoding来处理了，其实不是。decode则更简单，找到第一处`\r\n\r\n`，后面的就全部是有效数据。这两种方法，也被一些免流爱好者用来做免流客户端，原理就是有的ISP只看HTTP头中的Host字段，辅助VPS上的特殊端口，便能欺骗ISP的计费系统。

而random_head方法则更简单了。它会在ss的客户端和服务端连接建立起来后，先发一段随机长度（<104字节）的随机内容，其中最后4字节是前面内容的crc32检验值，之后才是ss加密的数据。这个混淆纯粹只是扰乱了原版ss协议开关固定的iv+地址的信息而已，不过对于某些ISP而言，大概也够用来欺负一下QoS了吧。

----

目前[C#](https://github.com/shadowsocksr/shadowsocksr-csharp/releases)版支持的混淆方法我这儿算是都支持了，就协议部分还在头疼中。等把最新的3个协议实现后，我打算把avege开源出去。昨天看到[原版ss libev](https://github.com/shadowsocks/shadowsocks-libev)版加入了[obfs4](https://github.com/Yawning/obfs4)实现，Surge据说也支持了，我觉得obfs4的实现比较累，先暂时不考虑吧。

----

现在在Win7/8/10上要用Wireshark抓本地回环的包，用Winpcap开混杂模式不行了，得装[npcap](https://github.com/nmap/npcap)，起源据说是几年前中国[某位学生](https://github.com/hsluoyz)的GSoC项目，佩服。