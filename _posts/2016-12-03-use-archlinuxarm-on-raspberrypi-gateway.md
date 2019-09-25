---
layout: post
image: https://blogimg.minidump.info/2016-12-03-use-archlinuxarm-on-raspberrypi-gateway.md
author: missdeer
title: "使用Archlinux做树莓派翻墙网关"
categories: embed
description: 使用Archlinux ARM系统做树莓派翻墙网关
tags: Archlinux raspberrypi GFW Go GccGo
---

从妹子家里拿回来的树莓派1B不知道出了什么问题，开机只能跑个一两天，之后就连不上网了，从路由器看它也掉线了，只能断电重启才能再次连上。连续遇到两次，我也没耐心继续耗下去了，打算重装系统，原本用着Raspbian，1B的机能实在差了点，于是想着装Archlinux这种比较轻量级的试试，另外一个想用Archlinux的原因是它的官方仓库里一般会有比较新的GccGo安装包，avege用Go开发，试试GccGo编译是否会有更好的性能表现。

从[Archlinuxarm](https://archlinuxarm.org/platforms/armv6/raspberry-pi)的网站上找到安装步骤和安装文件，把SD卡插在另一个2B+树莓派上很快就装好了，然后插回1B树莓派，上电开机，就能得到一个看起来比Raspbian要轻量点的系统。

有了一个可以跑的Archlinux系统，之后便是各种安装软件和设置操作：

- 修改软件源镜像到国内，我比较喜欢使用[中科大的源](https://mirrors.ustc.edu.cn)。
- 滚动升级一遍系统`pacman -Syu`，然后安装sudo，git和gcc-go包，这样最基本的能用普通账号工作的软件都有了。
- 用git取下avege的源代码，并把其他工作环境中用过的一些Go的第三方package源代码全都拷过来。
- 用GccGo编译avege：`GOPATH=$GOPATH:$PWD/../.. go install -gccgoflags="-s"`，遇到链接找不到符号的问题，报`https://golang.org/x/sys/unix/syscall_linux_arm.go`里用到的`seek`函数找不到具体实现，网上搜了一下没发现什么有用的信息。而且看代码发现只有ARM和386架构的Linux port才用到了这个函数，一头雾水。
- 放弃GccGo，从官网下载Go官方编译器套件，顺利编译通过。
- 安装avege运行时依赖的软件redis和dnsmasq，avege已能正确工作。
- 要把avege添加到systemd中开机自动运行，像Raspbian中那样添加一个`/etc/rc.local`文件已经不管用了，在archlinux的官方论坛找到一个[论坛回复](https://bbs.archlinux.org/viewtopic.php?pid=1211415#p1211415)可以解决这个问题。
- 要禁止dhcpcd修改`/etc/resolv.conf`，在Raspbian下用命令`chattr +i /etc/resolv.conf`就能解决的问题，在Archlinux下一直报`Operation not supported while reading flags on /etc/resolv.conf`，然后看到一个[简便办法](https://ubuntuforums.org/showthread.php?t=1978656&p=11968135#post11968135)，只要把软链接删掉，重新创建一个新文件就不会被修改了。

如此一番，再次重启树莓派，从DHCP得到一个IP后，局域网内其他机器可以用这个IP作为网关和DNS地址，实现翻墙了。

------

最近又有点中毒其他小板子，比如[Pine A64](https://item.taobao.com/item.htm?id=529150082445)，[Orange Pi Plus 2E](https://item.taobao.com/item.htm?id=531880721728)，[Banana Pi R1](https://item.taobao.com/item.htm?id=42722747273)，各有各的特点，比如64位，性能强，多网口。另外还知道了一个新的系统[DietPi](http://dietpi.com/)，据说优点是超轻量和为小板优化，有机会也得试试。
