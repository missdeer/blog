---
image: https://blogassets.ismisv.com/media/2022-11-03/topo.png
layout: post
author: missdeer
featured: false
title: "配置Debian路由器双WAN接入"
categories: network
description: "配置Debian路由器双WAN接入"
tags: TP-Link Debian 双WAN 分流
---

鉴于移动免费送了1年200M的一条宽带，没多犹豫决定还是要用起来。经过一番折腾，基本搞好了，目前的情况大概是这样的：

{% plantuml %}
@startuml
left to right direction
skinparam titleBorderRoundCorner 5
skinparam titleBorderThickness 1
skinparam titleBorderColor black
Node 弱电箱 {
title 家中网络拓扑
Node CTModem [
<b>电信光猫</b>
]
Node CMModem [
<b>移动光猫</b>
]
Node R86S[
<b>R86S软路由</b>
]
Node TPLinkSG1210P [
<b>TP-Link SG1210P</b>
....
PoE千兆交换机
@弱电箱
]
}
Node TPLinkSwitch [
<b>TP-Link千兆交换机</b>
....
@客厅
]

Node TPLinkSwitchBD [
<b>TP-Link千兆交换机</b>
....
@主卧
]
Node HTPC [
<b>HTPC</b>
....
一些服务程序
如Git Server等
]
Node APBedRoom1[
<b>主卧86面板AP</b>
....
5G WIFI
以太网口
]
Node APBedRoom2[
<b>次卧86面板AP</b>
....
5G WIFI
以太网口
]
Node APDinnerRoom[
<b>餐厅86面板AP</b>
....
2.4G & 5G WIFI
以太网口
]
Node APLivingRoom[
<b>客厅86面板AP</b>
....
2.4G & 5G WIFI
以太网口
]
Node TLAC100[
<b>TL-AC100</b>
]
Node MacMini[
<b>MacMini</b>
....
吃灰备用
]
Node TinyMonster[
<b>Windows小主机</b>
....
主力开发机
]
Node Debian[
<b>Debian</b>
....
曾经的主力旁路由
@PVE
]
Node FreeBSD[
<b>FreeBSD</b>
....
学习实验用
@PVE
]

Node NetBSD[
<b>NetBSD</b>
....
学习实验用
@PVE
]

Node OpenBSD[
<b>OpenBSD</b>
....
学习实验用
@PVE
]

Node DragonflyBSD[
<b>DragonflyBSD</b>
....
学习实验用
@PVE
]
Node WinDesktop [
<b>Windows台式机</b>
]
Node TLIPC40CFocus[
<b>TP-Link监控摄像头</b>
]
Node TLIPC40C[
<b>TP-Link监控摄像头</b>
]

Node Chromecast[
<b>Chromecast</b>
]
Node SonyTV[
<b>电视机</b>
]
Node DoorLock [
<b>智能门锁</b>
]
R86S-ri->CTModem 
R86S-le->CMModem 
TPLinkSG1210P --> R86S
TPLinkSwitch --> TPLinkSG1210P 
APBedRoom1-->TPLinkSG1210P 
APBedRoom2-->TPLinkSG1210P 
APDinnerRoom-->TPLinkSG1210P 
APLivingRoom-->TPLinkSG1210P 
HTPC-->TPLinkSwitch 
TPLinkSwitchBD -->APBedRoom1
TLAC100-->TPLinkSwitchBD 
WinDesktop-->TPLinkSwitchBD 
Debian-->TPLinkSwitchBD 
FreeBSD-->TPLinkSwitchBD 
NetBSD-->TPLinkSwitchBD 
OpenBSD-->TPLinkSwitchBD 
DragonflyBSD-->TPLinkSwitchBD 
MacMini-->TPLinkSwitchBD 
TinyMonster-->TPLinkSwitchBD 
TLIPC40CFocus-->APDinnerRoom
DoorLock-->APLivingRoom
SonyTV-->APLivingRoom
TLIPC40C-->APLivingRoom
Chromecast-->APLivingRoom
@enduml
{% endplantuml %}

2年前也写过[文章](/2020/04/add-tl-ac100/)提到过家里的网络拓扑，大的变化没有，只是加了一些新设备。现在在原有电信宽带的情况下，新增一条移动宽带，主要就是把接入路由器换了，原本的TP-Link R470GP只能接入一个WAN，正好目前R86S比较火，买了个最便宜的版本，先不考虑自己折腾猫棒，能双线以太网口接入就行。另外从闲鱼收了一个TP-Link SG1210P，索性把所有面板都从同一个交换机连上，情况会简单很多。

TP-Link SG1210P有3种工作模式，其中VLAN模式和视频监控模式，LAN中的设备只能与上游接入设备通信，我这里客厅的HTPC要与主卧的诸多设备互通，所以要把TP-Link SG1210P切换到标准模式。

剩下的工作就是把R86S配置好，顺便把原来HTPC/Debian上的科学上网工作也移到R86S上。我给R86S装了最新的Debian 11，网上看其他做软路由的文章/视频99.9%是刷OpenWRT，我为什么不用呢，有几个原因：

1. 首先最重要的是，Debian是我最喜欢的Linux发行版，没有之一。从图上可以看到，客厅的HTPC，主卧的曾经的主力旁路由，都是装的Debian，我所有的VPS上也都用的Debian。
2. 其次，我觉得OpenWRT的可玩性不如Debian好，Debian做路由系统需要自己动手做的事更多，但另一方面讲也更自由。
3. Debian官方仓库的软件包更多更可信，OpenWRT这方面差一点，系统和软件包的魔改版本太多，全都自己编译的话太费时费力。
4. 最后，对OpenWRT的质量不太信任，之前[买了个GL.iNet MT1300](/2021/01/gl-inet-mt1300/)，刷的是厂商定制的OpenWRT，升级系统没一次是没问题的。而我这么多不同硬件环境下的Debian系统大版本升级没一次是有问题的。

再来讲如何将Debian配置成一个路由器。我的R86S是最低配的那款，只有3个以太网口，规划好3个口的用途，将外壳上标记的eth0和eth1作为WAN口，连接运营商的光猫，eth2作为LAN口，连接屋内的交换机。

首先，在sysctl中将包转发功能打开（我不使用IPv6，不实用），root打开文件`/etc/sysctl.conf`，顺便把BBR也打开：

```txt
net.ipv4.ip_forward=1
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
```

再运行一下`sysctl -p`使其生效。

然后配置网络连接，我有3个网口，分别是`enp1s0`，`enp2s0`，`enp3s0`，前2个分别接入电信和移动宽带，第3个作为LAN，编辑`/etc/network/interfaces`：

```txt
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp1s0
iface enp1s0 inet dhcp
#iface enp1s0 inet6 dhcp

auto enp2s0
iface enp2s0 inet dhcp
#iface enp2s0 inet6 dhcp

auto enp3s0
iface enp3s0 inet static
    address 192.168.233.1
    netmask 255.255.255.0
```

如果想用IPv6，可以把`inet6`那两行注释去掉，我不用，所以就注释掉了，都使用DHCP从光猫获取IP。把内网网段设为`192.168.233.x`，本机作为路由器即网关，就用`192.168.233.1`。再设置一下iptables转发参数，运行命令：

```bash
iptables -t nat -A POSTROUTING -o enp1s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o enp2s0 -j MASQUERADE
```

这时已经可以上网了，比如敲个命令`curl www.baidu.com`看一下，可以得到返回的内容。如果有其他设备接入enp3s0的口，并手动将IP和子网掩码，网关分别设置到`192.168.233.x`，`255.255.255.0`，`192.168.233.1`，其中x是[2，255]间的整数。

接着使用dnsmasq作为DHCP服务器。安装好后编辑配置文件`/etc/dnsmasq.conf`：

```txt
interface=enp3s0
dhcp-range=192.168.233.200,192.168.233.250,255.255.255.0,12h
dhcp-option=option:router,192.168.233.1
dhcp-option=option:dns-server,192.168.233.1
```

内容很简单：第1行，将服务绑定到第3个网口，第2行，设定自由分由的IP地址池以及有效时间，第3行，告知客户端使用的网关IP，第4行，告知客户端使用的DNS服务器地址。还可以绑定IP和mac地址，这样可以在后续针对某个设备做些特殊的设置：

```txt
dhcp-host=00:e0:4c:68:2a:5f,192.168.233.166
dhcp-host=00:e0:4c:68:2a:60,192.168.233.66
dhcp-host=00:1E:65:41:73:C2,192.168.233.16
```

这里我将本机作为DNS服务器，dnsmasq本身也是一个DNS服务器程序，但我习惯使用CoreDNS，在[以前的文章](/2019/07/coredns-no-dns-poisoning/)中详细讲过。

最后是配置一下分流策略，我没拿双线做负载均衡和故障转移，因为我觉得电信1000M和移动200M接入以我家里平常的使用习惯，以及凭目前的服务质量可能一年都碰不到一次需要用另一根线的情况。而流量分流的话，可能在访问某一些服务器时延迟能减少几毫秒（误！我的策略很简单，如果目的IP是归属移动的，则走移动线，否则走电信线。需要分本机流量和非本机流量两种情况处理，先处理非本机的情况，从`https://ispip.clang.cn/`下载归属移动的IP地址段列表，然后添加到一个ipset中，命令如下：

```bash
rm -f /tmp/cmroute.txt
curl -sSL https://ispip.clang.cn/cmcc_cidr.txt | while read line
do
    echo "add cmroute $line" >> /tmp/cmroute.txt
done
ipset create cmroute hash:net family inet hashsize 1024 maxelem 512
ipset restore -f /tmp/cmroute.txt
```

然后给`enp3s0`的流入流量打个标签：

```bash
iptables -A PREROUTING -i enp3s0 -t mangle -m set --match-set cmroute dst -j MARK --set-mark 10
```

再给移动线建一个新的路由表（假设叫table 10）并打了标签的流量都导到这个路由上去（192.168.1.6是移动光猫分配出来的IP）：

```bash
ip rule add from 192.168.1.6 table 10
ip rule add fwmark 10 table 10
ip route add 192.168.1.0/24 dev enp2s0 src 192.168.1.6 table 10
ip route add default via 192.168.1.1 dev enp2s0 table 10
```

这时接入到enp3s0口的设备访问移动网络的IP时就会走移动线路了，可以打开移动官网或手机app，感觉似乎真的快了一点点呢！

最后，把本机的流量也分一下，直接改主路由表就行了：

```bash
curl -sSL https://ispip.clang.cn/cmcc_cidr.txt | while read line
do
    ip route add $line dev enp2s0
done
```

路由器的基本设置就完成了。另外还可以弄一下科学上网等，这是另一个话题了，暂且略过。
