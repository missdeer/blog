---
layout: post
image: https://blogimg.minidump.info/2015-07-22-enable-ipv6-with-nginx-on-linode.md
author: missdeer
title: "Linode上nginx开启IPv6支持"
categories: network
description: Linode上nginx开启IPv6支持
tags: IPv6 Linode nginx
---
之前就发现了，Linode是默认带一个IPv6地址的，最近公司里的项目要做一点跟IPv6相关的工作，我就想多了解点IPv6相关的东西，于是想到把我的web站点支持IPv6。

其实过程很简单，首先加一条DNS记录，AAAA指向IPv6地址。这时可以用命令`dig yii.li AAAA`查看是否生效：

```
$ dig yii.li AAAA

; <<>> DiG 9.8.3-P1 <<>> yii.li AAAA
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3703
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 4

;; QUESTION SECTION:
;yii.li.				IN	AAAA

;; ANSWER SECTION:
yii.li.			300	IN	AAAA	2400:8900::f03c:91ff:fe73:f280

;; AUTHORITY SECTION:
yii.li.			3600	IN	NS	kurt.ns.cloudflare.com.
yii.li.			3600	IN	NS	olga.ns.cloudflare.com.

;; ADDITIONAL SECTION:
kurt.ns.cloudflare.com.	2548	IN	A	173.245.59.193
kurt.ns.cloudflare.com.	2548	IN	AAAA	2400:cb00:2049:1::adf5:3bc1
olga.ns.cloudflare.com.	30057	IN	A	173.245.58.137
olga.ns.cloudflare.com.	30057	IN	AAAA	2400:cb00:2049:1::adf5:3a89

;; Query time: 356 msec
;; SERVER: 64.104.123.245#53(64.104.123.245)
;; WHEN: Wed Jul 22 09:44:01 2015
;; MSG SIZE  rcvd: 195
```


然后修改nginx配置：

```
listen      [::]:80 ipv6only=on;
listen      80;
listen      [::]:443 ssl spdy ipv6only=on;
listen      443;
```

后面的`ipv6only=on`这种选项在整个配置中只要加一次就行了。重启nginx，看一下监听端口：

```
$ netstat -anltp | grep "\(443\|80\)"
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
tcp        0      0 0.0.0.0:80                  0.0.0.0:*                   LISTEN      -                   
tcp        0      0 0.0.0.0:443                 0.0.0.0:*                   LISTEN      -                 
tcp        0      0 :::80                       :::*                        LISTEN      -                   
tcp        0      0 :::443                      :::*                        LISTEN      -
```

最后，如果自己有IPv6环境，就访问一下，没有的话可以在[http://ipv6-test.com/validate.php](http://ipv6-test.com/validate.php)测一下看看是否生效。

BTW，我这blog也是支持IPv6的。

```
$ dig blog.minidump.info ANY 

; <<>> DiG 9.8.3-P1 <<>> blog.minidump.info ANY
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 59877
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 2, ADDITIONAL: 4

;; QUESTION SECTION:
;blog.minidump.info.		IN	ANY

;; ANSWER SECTION:
blog.minidump.info.	5	IN	A	104.28.31.28
blog.minidump.info.	5	IN	A	104.28.30.28
blog.minidump.info.	5	IN	AAAA	2400:cb00:2048:1::681c:1f1c
blog.minidump.info.	5	IN	AAAA	2400:cb00:2048:1::681c:1e1c

;; AUTHORITY SECTION:
minidump.info.		4211	IN	NS	anna.ns.cloudflare.com.
minidump.info.		4211	IN	NS	ed.ns.cloudflare.com.

;; ADDITIONAL SECTION:
ed.ns.cloudflare.com.	84448	IN	A	173.245.59.111
ed.ns.cloudflare.com.	84448	IN	AAAA	2400:cb00:2049:1::adf5:3b6f
anna.ns.cloudflare.com.	63572	IN	A	173.245.58.102
anna.ns.cloudflare.com.	63572	IN	AAAA	2400:cb00:2049:1::adf5:3a66

;; Query time: 165 msec
;; SERVER: 64.104.123.245#53(64.104.123.245)
;; WHEN: Wed Jul 22 09:58:33 2015
;; MSG SIZE  rcvd: 265
```
