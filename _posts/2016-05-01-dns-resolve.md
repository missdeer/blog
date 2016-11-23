---
layout: post
title: "纯净DNS解析"
categories: gfw 
description: 纯净DNS解析
tags: DNS GFW
---
DNS污染主要是两种，一是丢包，二是抢答，两种方式基本上无规律出现。做纯净DNS解析基本上就是为了解决这两个问题，现在主流的方法大体有以下几种：

* 换DNS服务器。一般ISP会自动分配一个或两个DNS服务器，这种服务器对于国内或ISP内网的CDN特别友好，但对国外的比如Apple的CDN就抓瞎了，所以有了114，阿里，DNSPOD之类的公共DNS服务器，针对用户常用的Apple等CDN做了优化，但它们不能解决DNS污染的问题，所以需要用8888之类国外的DNS来解决污染。
* 换端口。一些国外的知名DNS服务器树大招风了，标准的DNS使用53端口仍然会被污染，于是像OpenDNS之类一些公共DNS服务除了53端口外还在诸如443，5353等端口提供DNS解析服务，有些ISP还没针对非标准端口进行污染，但操作系统对DNS解析的操作仅支持标准的53端口，所以需要额外的软件把请求端口从53转发过来。
* 换协议。操作系统在进行DNS解析时使用的是UDP协议，但现在有一些公共DNS服务器，比如8888，OpenDNS等提供了TCP之类的传输协议进行解析，除此之外还有TCP-TLS，也是个标准化的协议，但我是没见到过有哪家公共DNS服务器支持了，还有DNSCrypt，是OpenDNS在TCP之上实现的一种加密传输协议。跟换端口一样，为了让操作系统能够使用，所以也需要额外的软件实现协议。
* 代理。DNS解析本身也是一次数据传输，DNS污染就是对数据传输进行了阻碍和修改，所以代理就是让DNS协议走在一条相对可靠的传输线路上，除了可以直接对DNS协议本身即UDP代理，还可以通过DNS over VPN之类的方式代理，比如shadowsocks-libev版有一个ss-tunnel工具，可以把远端主机的端口映射到本地的端口，如果把8888的53端口映射到本地53端口，那么相当于开通了一条走shadowsocks协议的DNS代理。

有了纯净DNS，基本上浏览被墙网站是没问题了。不过功能实现后，就该考虑优化了，因为上面提到的方法最后都是让国外的DNS服务器进行最终的解析，所以对国内的CDN基本无解。现在常用的方法基本上是分流解析，国内域名让国内DNS服务器解析，国外域名让国外DNS服务器解析，细微的差别就在于如何判断出一个域名需要让哪边的DNS服务器解析。

* ChinaDNS基本上停更了，最早的版本是维护了一个IP黑名单，这是基于这么一个假设，即GFW抢答给出的IP属于一个并不大的集合，于是只要收到了黑名单中的IP时，就走纯净DNS解析。后来的版本改成同时向国内外的DNS服务器请求，如果得的IP是国外的，则取纯净DNS解析结果，否则取国内DNS解析结果。这是基于这么一个假设，国外的DNS解析结果总是纯净的，并且总是比国内的DNS解析结果晚到。
* PCap_DNSProxy，28小朋友至今一直在积极更新，用C++开发，依赖libpcap/Winpcap，从驱动层抓捕到DNS解析返回的UDP包，把GFW抢答的包丢弃，以此来获得纯净DNS解析结果。实际上如何辨别出一个DNS应答包是抢答的是件很费神的事，28小朋友对此也有点诲莫如深。除此之外它还有一系列跟DNS解析相关的功能，比如CNAME hosts之类的。
* dnsmasq+china domain list。我觉得这是最unix-like style的方案，作者Felix Yan也是Archlinux的开发者，维护了一个包含几千个域名的国内网站域名列表，配合dnsmasq，可以让这些域名走国内的DNS服务器解析，其他域名默认走纯净DNS解析。

[avege的方案](https://blog.minidump.info/2016/03/avege-dns-improve/)基本上糅合了以上几种方案中简单又有效的部分，目前基本工作正常。唯一比较遗憾的是没有直接支持DNSCrypt。