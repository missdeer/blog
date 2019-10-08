---
image: https://blogimg.minidump.info/2019-10-08-surf-internet-properly-2.md
layout: post
author: missdeer
featured: false
title: "最合理的科学上网姿势(续)"
categories: gfw
description: 总结出来目前最合理的科学上网姿势
tags: GFW redsocks gateway shadowsocks
---
[之前提到](../../09/surf-internet-properly/)科学上网为不同目的IP走不同的线路，导致加了16000多条iptables规则，太大的iptables表将会导致路由器性能下降。

经人[提醒](https://twitter.com/duyaoo_/status/1181030991227305984) ，可以使用ipset配合缩减iptables表大小，[性能会好很多](https://twitter.com/duyaoo_/status/1181033427249725440) 。于是写了点代码，仍然是根据[APNIC](http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest) 的数据自动生成[iptables](https://github.com/missdeer/avege/blob/4cda819d62aa3f9ab9896b73acfa126ad92de7cf/rule/iptables_rules_gen.go#L18) 和[ipset导入数据](https://github.com/missdeer/avege/blob/4cda819d62aa3f9ab9896b73acfa126ad92de7cf/rule/iptables_rules_gen.go#L70) 。然后用命令导入：

```bash
iptables-restore < rules.v4.latest
ipset destroy
ipset restore -f ipset.txt
```

截止到现在，路由器上的iptables规则连带正而八经的端口映射、防火墙端口过滤等规则，总共不到80条！

![iptables](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-10-08/iptables.png)

具体效果没有详细测试，先用一段时间感性体会一下。