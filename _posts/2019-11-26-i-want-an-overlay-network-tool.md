---
image: https://img.peapix.com/2c2e6f2cb5c84a11b457847da0328b2d_320.jpg
layout: post
author: missdeer
featured: false
title: "我想要的overlay网络工具"
categories: network
description: 简单记录一下我当前想要的overlay网络工具该是怎么样的
tags: 
  - nebula
  - tinc
  - zerotier
  - gnb
  - ngork
  - frp
  - tun
  - asio
---

> **2022年5月更新**：gnb早已开源并更名为OpenGNB，所有源代码可在[GitHub](https://github.com/gnbdev/opengnb)下载，且可自行编译。

---
前些天Slack开源了他们的一款overlay网络工具[Nebula](https://github.com/slackhq/nebula)，简单地说，就是一款VPN，支持一定程度的P2P及内网穿透，这类工具正是我一直来有比较强烈需求的。我的需求侧重点主要在主机互连和内网穿透上，翻墙不在此列，我对翻墙的理念以前的blog上略有提及，跟VPN几乎风马牛不相及。

在Nebula之前，我用过很多款工具，最早用过[ngork](https://github.com/inconshreveable/ngrok)、[frp](https://github.com/fatedier/frp)，后来还用过[OpenVPN](https://openvpn.net/)、[ZeroTier](https://www.zerotier.com/)、[tinc](https://www.tinc-vpn.org/)，再后来用过某微信群里一大佬自己开发的商业程序gnb的beta版，到现在全都因为各种原因没继续使用下去。

就我实际用下来的感受，ngrok和frp都只是比较单纯的内网穿透工具，功能比较单一。

tinc 基本走 TCP，虽然宣称有时候会走 UDP，但没见到过，也没见过它 2 个内网机器 p2p 穿透直连（所说有，但我没遇上），配置也更麻烦一点，用过段时间放弃了。 
ZeroTier 也用过一小阵子，web 配置界面是方便很多，但几乎所有流量都中转的样子，太慢了，受不了。可以自建[Moon](https://www.zerotier.com/manual/#4_4)，放在国内的话大概可以减小延迟。

前段时间用了一阵子gnb的 beta 版，跟 Nebula 的做法比较类似，走 udp，但不开源，也不能绑定到本地的某一个网卡用（大概后面的版本已经可以了），性能好得多。

目前看来 Nebula比前几者都要好一些。但也有些小问题，比如2个节点间互连需要一小会儿或一大会儿才能连上等等。

前些天（半个多月前开始）我甚至开始想自己写一个类似的工具，基于以下想法：

1. 用tun/tap接口，也是几乎所有类似工具使用的方式；

2. 跨平台，这也是刚需，毕竟现在设备类型和操作系统那么多；

3. 配置方便，ZeroTier是典型，gnb和tinc就是反面教材，Nebula算中间；

4. 用UDP，一则方便内网穿透，二则延迟比TCP好得多；

5. 既有UDP打洞方式穿透，又有[UPnP](https://en.wikipedia.org/wiki/Universal_Plug_and_Play)方式穿透；

6. 用[KCP](https://github.com/skywind3000/kcp)和[FEC](https://en.wikipedia.org/wiki/Forward_error_correction)，一则实现UDP可靠传输，二则带宽和速率都能提上来；

7. 可以将UDP伪装成TCP，逃避ISP的[QoS](https://en.wikipedia.org/wiki/Quality_of_service)以及某些防火墙（比如我上班这地儿）的阻断；

8. 可配置加密算法，某些arm板上用[AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)略显烧板，要允许用[chacha20](https://en.wikipedia.org/wiki/Salsa20#ChaCha_variant)之类的；

9. 支持多个网络连接，不同网络连接使用不同配置，比如我有2条线路，一条对海外线路友好，另一条对国内线路友好，那就需要将不同流量从不同网络连接走出去了；

暂时就想到这些，然后就看到Nebula开源了，试了试用Nebula把公司和家里的设备连起来后，发现它1~4基本有了，5有一半，6~9没有，感觉还是可以自己搞一搞的。
