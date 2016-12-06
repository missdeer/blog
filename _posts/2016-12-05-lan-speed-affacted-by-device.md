---
layout: post
title: "设备对局域网网速的影响"
categories: network
description: 路由器、网关等设备对局域网网速的影响
tags: Router Gateway LAN raspberrypi
---

屋里的网络突然变得很慢，连打开百度首页、电信首页都非常吃力，转圈很久仍然有不少图片不能加载出来，重启了光猫和所有路由器，仍然没有改善，最后是通过打电话给电信客服，让客服在他们那边重启了一下什么设备或是线路才搞定。

趁这个机会我却正好测试了一下屋里各个路由器、网关等设备对局域网网域的影响。

屋里拉了电信的100M宽带，光纤连到一个单口光猫上，光猫通过网线连到一个极路由1S的WAN口，再从极路由的某个LAN口拉网线连到一个TPLink的8口千兆交换机，最后从交换机拉网线连到Netgear R6300v2的WAN口。光猫是桥接模式，由极路由负责拨号，家里的设备基本上都连R6300v2上，除了两个树莓派是连到极路由的LAN上，作为翻墙网关。

其实拨号R6300v2也可以，但R6300v2不能为DHCP指定自定义的网关IP，所以只能在前面加一个极路由，在R6300v2的WAN侧把网关和DNS指向树莓派。

电信客服建议我先试试电脑跳过路由器，直连光猫拨号测试一下网速。本来我也没抱多大希望的，一来对电信的线路没信心，二来对老旧的单口光猫没信心，但觉得也不是很麻烦，于是拿MBP从Thunderbolt转以太网连光猫拨号上网，在Terminal中用curl下载163镜像中的一个大文件测试：`curl -o /dev/null http://mirrors.163.com/centos/7/isos/x86_64/CentOS-7-x86_64-Everything-1511.iso`，然后被惊到了，如此单线程http下载居然达到了13MBps+！

接着，我把MBP连到极路由上，让极路由拨号，再用相同命令进行测试，结果在7-8MBps徘徊。由此可以极路由上性能损失还是很严重的。

之后，我把MBP连到R6300v2上，还原了一直在用的拓扑，但把R6300v2的WAN口网关改为极路由的IP。用相同的命令进行测试，结果也在8MBps左右。

然后，我把R6300v2的WAN口网关改为树莓派2B的IP，该树莓派使用Raspbian系统，其上运行着[一些程序](/2016/10/my-busy-raspberry-pi/)，结果只在500-950KBps之间徘徊，而且总是下载10MB左右就连接中断了。

最后，我把R6300v2的WAN口网关改为树莓派1B的IP，该树莓派使用Archlinux系统，上面只运行了一翻墙程序，结果也3-4MBps左右，基本上是跑满了这个树莓派的总线带宽。

由此可见，局域网网速的瓶颈在于极路由和树莓派上，我觉得可以把这两个东西替换为一个[Banana Pi R1](https://item.taobao.com/item.htm?id=42722747273)，上面只跑最简单的拨号、路由和翻墙程序，然后又有千兆的WAN口和LAN口，理想情况下应该可以跑满接入带宽了。