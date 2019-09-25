---
layout: post
image: https://blogimg.minidump.info/2017-02-05-ipv6-at-home-follow-up.md
author: missdeer
title: "在家部署IPv6后续"
categories: network
description: 搞定二级路由Netgear R6300v2支持IPv6
tags: IPv6 Router
---

之前在香蕉派上通过he.net的tunnel得到IPv6后，遗留下一个问题，二级路由器Netgear R6300v2刷了梅林固件后，不能分配内网IPv6地址，网上看也有人提出了相同的问题，后来在其他人的[指点](https://www.v2ex.com/t/336608#reply1)下，找到解决这个问题的[几个办法](http://koolshare.cn/thread-46415-1-1.html)。

经过简单的比较，我的路由器在web管理界面上有一个web shell，但我不知道怎么安装其他软件，于是我采用了方案二，固件中打开IPv6支持后，先把`6relayd`可执行文件上传到路由器中，我用web管理界面的上传功能失败了，靠另外建了一个web server再在路由器上用`curl`下载下来。然后用`ifconfig`看看路由器上WAN和LAN接口名字，分别是eth0和br0，在web shell执行命令`/jffs/bin/6relayd -d -A eth0 br0`即可，`-d`表示后台运行，`-A`表示relay模式。最后设置一下IPv6的防火墙：

```
ip6tables -F
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
```

这时再用`ifconfig`看LAN口上也有了IPv6地址，再看其他接入该路由器的系统，也都分配了IPv6地址。可以用浏览器打开网站[IPv6 Test](http://ipv6-test.com/)查看效果。

现在屋里全网IPv4/IPv6 dual stack了。