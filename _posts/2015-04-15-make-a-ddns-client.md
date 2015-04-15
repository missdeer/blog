---
layout: post
title: "写了个DDNS客户端"
categories: coding
description: 写了个伪动态DNS客户端
tags: DDNS DNSPOD Cloudflare Oray pubyun
---
前几天发现公司网络有个奇怪的问题，公司的DNS解析居然把花生壳（oray.com）和公云（pubyun.com）的域名给劫持了。

我在家里放了个7*24在线的树莓派，然后用cron每分钟用curl调用花生壳和公云的API刷新一下自己的IP，再把一个有泛域名证书的二级域名CNAME到公云的动态域名上，打开443端口，就可以在外面通过https查看树莓派上的文件，还可以通过ssh反连回去。结果这一套在公司里行不通了，虽然用dig指定公用的DNS服务器可以得到真正的IP地址，然后填到hosts文件里，就可以暂时解决这个问题，但鉴于电信IP的分配策略，我这三个月来发现公网IP基本是每72小时会变一下，那每次自己都手动改一下hosts文件还不得烦死。

后来发现似乎公司只是劫持了花生壳和公云的动态域名，其他自己申请的域名没有问题，然后又知道dnspod是有公开API的，所以说干就干，今天断断续续写了几个小时用Go写了个小程序每分钟刷新一下域名A记录。代码放到[github](https://github.com/missdeer/ddnsclient)上了，就一个代码文件和一个配置文件。支持使用http basic auth的服务，比如花生壳和公云，其实现在很多家用路由器都带这个客户端了，但我自己用过一段时间发现不稳定，自己写个也不复杂。还支持dnspod和cloudflare，因为我在这两家都有几个域名在解析。用Go写的好处是很容易交叉编译生成树莓派上可以运行的二进制可执行文件，就可以替换原来的cron记录了。