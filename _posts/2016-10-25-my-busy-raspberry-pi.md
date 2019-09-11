---
layout: post
author: missdeer
title: "我忙碌的树莓派"
categories: embed
description: 我的树莓派很忙
tags: raspberrypi
---
之前想着要换软路由，不但把拨号的极路由1S换掉，还要把翻墙网关树莓派也换掉。但看了一下我的树莓派，还真承担了很多任务呢！

1. 定时签到。买的翻墙服务可以每天签到一次，获取额外的1-5小时不等的使用时长，这个工作目前是个小程序自动完成的，放在树莓派上每天定时执行。
2. 防污染DNS。翻墙必须，自己写的程序实现国内外主机分流解析DNS，前端套了个dnsmasq。
3. Shadowsocks。翻墙必须，自己写的程序实现ss客户端，服务是花钱买的。
4. 自动更新iptables规则。翻墙必须，实现国内外主机分流，从APNIC的文件中解析出中国大陆的IPv4地址，再转成iptables规则并应用。APNIC的文件更新还比较频繁，于是我也做成每天更新一次。
5. btsync，现在叫Resilio了，树莓派上当主机，目前主要用来同步Keepass的密码库。
6. aria2c，下载机，虽然用得不多，但偶尔还是会从PT下个片什么的。
7. 动态DNS。自己的域名放在cloudflare和dnspod，就写了个小程序定时更新。
8. git，与github/bitbucket互为备份。
9. samba，其实也用得不多，但偶尔要用时很方便。
10. nginx，http接口很方便，比如从外面连回家里的路由器设置界面，aria2c的管理界面，临时下载文件链接，下完的片在其他设备（比如iPad）上通过http观看等等
11. redis/mysql，在家里写些程序时可供测试使用。

这样看来我的树莓派真的很有用啊！要迁移也得花不少时间呢！
