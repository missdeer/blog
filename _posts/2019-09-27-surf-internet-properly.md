---
image: https://blogimg.minidump.info/2019-09-27-surf-internet-properly.md
layout: post
author: missdeer
featured: false
title: "最合理的科学上网姿势"
categories: gfw
description: 总结出来目前最合理的科学上网姿势
tags: GFW redsocks gateway shadowsocks
---
前段时间路由器莫名其妙起不来之后，折腾了一下`tun2socks`，虽然在macOS和Windows上都能勉强工作，但总觉得操作麻烦，有一天我在MBA上用完后没有恢复路由表，第二天家里妹子就告诉我好像网坏掉了（手动狗头。所以最终还是需要在路由器上解决这个问题。

上周某一天我不死心地再次重启那挂掉的路由器，想看看有没有死灰复燃，结果真是令我喜出望外，它居然起来了！然后顺便调整了一下科学上网的姿势，给停用大半年的某机场先续费一个月，它家陆续推出二级（30元/月）和三级（60元/月）的线路后，一级（20元/月）的线路总感觉质量有所下降，不过先凑合用吧，等有钱了再升级。

我写了些[代码](https://github.com/missdeer/avege)，用于生成haproxy的配置文件、ss-redir的启动脚本、以及iptables的持久化文件。其中haproxy的配置文件中按线路所属地区分组，比如香港、日本、台湾、新加坡、美国、欧洲分别各自归为一组进行负载均衡，每一组在本地监听一个端口，ss-redir的启动脚本里分为每一组启动一个ss-redir进程通过haproxy的负载均衡连接机场服务器。最后在iptables中，根据APNIC为不同地区的IP指向不同的端口进行分流。

这是我觉得目前比较合理的科学上网姿势，能比较充分地利用机场提供的所有线路。不过这个方案有一些缺陷：

1. iptables记录数量太大，会大大降低网速。
2. 上网设备不在本路由器下时没法利用本方案的。

针对这些缺陷，我也想过一些办法，但还没实施：

1. 优化iptables表，比如[bestroutetb](https://github.com/ashi009/bestroutetb) 项目，[原理](https://ashi009.tumblr.com/post/36581070478/%E7%BF%BB%E5%A2%99-vpn-%E6%9C%AC%E5%9C%B0%E8%B7%AF%E7%94%B1%E8%A1%A8%E7%9A%84%E4%BC%98%E5%8C%96)在[这里](https://ashi009.tumblr.com/post/36581070478/%E7%BF%BB%E5%A2%99-vpn-%E6%9C%AC%E5%9C%B0%E8%B7%AF%E7%94%B1%E8%A1%A8%E7%9A%84%E4%BC%98%E5%8C%96)，但2个算法说明我都没看懂。
2. 上网设备与路由器之间再建一个虚拟专网，在外时通过虚拟专网连回来，便能享受到路由器的科学上网服务了。以前我用OpenVPN搭过，事实证明是可行的，但OpenVPN的server配置很tricky，我并不能每次都搞好。也可以考虑一下其他的方案。