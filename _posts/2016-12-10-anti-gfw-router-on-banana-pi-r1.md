---
layout: post
image: https://img.peapix.com/597671781561029479_320.jpg
author: missdeer
title: "用Banana Pi R1做一个翻墙路由器"
categories: Router
description: 用Banana Pi R1做一个翻墙路由器
tags: Router GFW ARM BananaPi
---

前面一直在说要把极路由和树莓派换掉，其实这个念头有很久很久了，最早是一年多前就想攒个小主机或家庭服务器，由于NUC、Gen8的价格远远超出我的预算，所以后来就考虑像占美之类的小主机，还是觉得贵，再后来考虑过二手的Atom主板来组，在淘宝翻了几天，觉得水很深，想来想去还是ARM板比较合适，偶然发现[Banana Pi R1](http://www.banana-pi.org.cn/r1.html)这块ARM板，CPU和内存其实跟最新版的树莓派从数据上看差不多，但关键是它有千兆网口，而且是5个口，1个WAN和4个LAN口！然后偶然发现了[Banana Pi的官方Telegram群](https://telegram.me/bananapicn)，询问了一些我关心的问题后，觉得R1是很适应我的需求，于是上淘宝买一块，昨天收到，包括一块板子，一块散热片，一块TF卡，一个输出5V3A DC的电源。贪便宜在另一家拍了一个外壳，快一周了也没发货，郁闷。

昨天晚上就开始折腾，本来打算装Archlinux的，不过这个比树莓派上的要麻烦，本来我想照archlinuxarm.org上[for Cubieboard 2的安装说明](https://archlinuxarm.org/platforms/armv7/allwinner/cubieboard-2)做的，但除了拷入archlinux的文件外，还需要另外刷入对应的uBoot bootloader的，但是我并不能确定它用的是哪一个包，照网上[某个帖子](http://forum.lemaker.org/thread-23135-1-1.html)说的刷了linux-sunxi的某个uBoot bootloader和Cubieboard 2的boot.scr，然后板子并不能点亮，于是我便放弃了，还是老老实实刷Raspbian吧，开箱即用，适合小白。

Raspbian镜像也是从[Banana Pi的官网](http://www.banana-pi.org.cn/r1-download.html)上下载的(我居然没用官网上那个archlinux镜像试试！)，写到TF后直接就能点亮板子了。然后跟树莓派上一样，从路由器上找到DHCP分配给它的IP，从SSH登录进去，用户名密码分是pi和bananapi，这个密码是我猜出来的，竟然没在哪里看到有说明！之后便是运行`raspi-config`，扩大分区容量，调整时区等等。到此为止，我就拥有了一个可以运行的基本的ARM系统了，之后便是进行翻墙路由器的配置。

做为翻墙路由器，要做这些事：

- 宽带拨号上网。这个是通过pppoe实现的，通过命令`sudo apt-get install pppoe pppoeconf pppoestatus`安装必要的软件，然后运行`sudo pppoeconf`进行拨号设置，基本上全都使用默认设置即可，填入宽带账号和密码，让它开机即拨号即可，平时可以用`sudo poff -a`停止拨号，或用`sudo pon dsl-provider`拨号。我发现甚至可以多拨，但在上海电信虽然能多拨成功，也能得到新IP，但貌似带宽并没有叠加，不过不排除是我的光猫下行带宽只有百兆，或者Raspbian本身没有把流量叠加，Bond可能正常工作。而且马上ppp0会断掉，然后ppp1即使存在也连不出去，所以多拨实际上还没什么用。另外就是昨天晚上折腾的时候，一运行`pppoeconf`，就板子掉电了，而且手去拿板子时会被电一下，连续发生了三次，只能拔插电源重新上电才行。怀疑了电源不稳，怀疑了光猫出来的网线带poe等等。今天再折腾时仍然无规律掉电，一次是编译程序时，一次是跑满带宽下载测速时等等。官方群里的人叫我用TTL看一下dmesg输出，我一直懒得找TTL线，就没看。我还怀疑是`pppoeconf`因为载入到内核中，是不是内核的问题，于是想着不用`pppoeconf`，装了`rp-pppoe`来配置，结果一运行`pppoe-start`就SSH连不上板子了，后来是撞大运般地运行完了`pppoeconf`才搞定的。
- DHCP服务器。从网上的各种文章说，`dnsmasq`就可以实现，但我怎么都弄不好，而且连DNS缓存都会搞坏，真是奇怪，我甚至怀疑板子掉电也有可能是`dnsmasq`引起的。后来就想用`udhcpd`来做这个，刚装好时倒是能工作了，后来重启了一次系统，`udhcpd`就不能运行了，没有任何错误信息输出，总之就是进程起不来，反复卸载重装再配置n次，也没用。最后用了`isc-dhcp-server`，配置还算简单，修改`/etc/dhcp/dhcpd.conf`，把IP范围，路由IP，DNS IP等等填入即可。
- 翻墙。这个跟之前在树莓派上完全一样，可以把树莓派2B上的程序原样copy过来直接使用。

另外有一些需要注意的点：

- 要做网关，需要打开包转发，即`/etc/sysctl.conf`里有一行`net.ipv4.ip_forward=1`，去掉开头的注释符号`#`，然后运行`sudo sysctl -p`使设置生效。也可以直接在shell上运行命令`sysctl -w net.ipv4.ip_forward=1`即可设置并生效。

- 要在iptables上做转发，运行命令`sudo iptables -t NAT -A POSTROUTING -s 192.168.0.0/16 -o ppp0 -j MASQUERADE`，我就是假设我就只用ppp0这个端口了。我现在还没搞好多拨，不然我觉得可能要用bond0这个端口。

- WAN口上是eth0，要给eth0设置一个静态地址，当成板子的IP，一般是192.168.x.1这种，修改`/etc/network/interfaces`：

  ```
  auto eth0
  allow-hotplug eth0
  iface eth0 inet static
    address 192.168.66.1
    netmask 255.255.255.0
  ```

  配合`isc-dhcp-server`在`/etc/dhcp/dhcpd.conf`在配置：

  ```
  subnet 192.168.66.0 netmask 255.255.255.0 {
    range 192.168.66.50 192.168.66.80;
    option routers 192.168.66.1;
  }
  ```

  如此其他电脑通过网线连到R1的任意一个LAN口，即可得到一个192.168.66.5x这样的IP，便可以通过`ssh pi@192.168.66.1`连接到板子上去了。

- pppoe虽然是通过WAN口走的，但它是会创建一个pppx的端口，所以不用担心eth0上的设置，从设置角度上看这两个是独立分开的。4个LAN口并不会有eth1...eth4这些端口，不要想多了。DHCP server是服务于eth0的，`isc-dhcp-server`会自己找range IP应该对应哪个端口（假设有多个端口的话，比如R1除了eth0还有wlan0）。

至今没确认掉电的root cause，不过我把电源换成了一个输出5V1.5A的，而且彻底不用`dnsmasq`了，跑了几个小时了，似乎没问题了。

到此为止，基本的翻墙路由器便能正常工作了，剩下的便是些周边工作，比如要在iptables里设置一下不能从外网连接进来，要做几个端口映射等等。