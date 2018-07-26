---
layout: post
title: "使用tinc构建虚拟专网"
categories: network
description: 使用tinc构建虚拟专网
tags: tinc
---

之前写过一篇文章讲如何[在家里无缝访问公司网络](../../../2018/04/access-internal-network-seamless/)，用的是[frp](https://github.com/fatedier/frp/)的方案，但正如使用[ngork](https://ngrok.com/)一样，frp也会莫名其妙地突然不工作，而且几乎没有什么错误信息可供调查。后来知道了有[zerotier](https://www.zerotier.com/)这个东西，相对来说还是比较稳定的，速度也凑合，免费额度可以在一个网络中添加最多100个设备，但是流量通过别人的服务器总归有点不爽，直到最近知道了[tinc](https://www.tinc-vpn.org/)这个东西，可用于创建点对点的虚拟专网。

经过近一天的折腾，终于把公司两台iMac，家里一台Linux HTPC，以及Linode东京1一台VPS用tinc连起来了。tinc的安装配置使用都非常简单，只不过网上的资料比较零散，有一些还是错的，其实只要看[linode的一篇文章](https://www.linode.com/docs/networking/vpn/how-to-set-up-tinc-peer-to-peer-vpn/)以及[tinc的官方文档](https://tinc-vpn.org/documentation/tinc.pdf)，基本能解决所有tinc相关问题。

tinc的工作方式依赖于tuntap，现在的Linux发行版基本上都已经带了tuntap驱动，所以直接从官方仓库使用相应的命令安装tinc就能工作。在macOS上则需要自己安装一个tuntaposx驱动，可以通过`brew cask install tuntap`进行安装，也可以自己从[网上](http://tuntaposx.sourceforge.net/download.xhtml)下载安装包手动安装，甚至可能直接安装一个[tunnelblick](https://tunnelblick.net/)都会自动装一个驱动。可以用命令行`kextstat |grep -e tun -e tap` 看一下是否已经安装成功，如果没有任何输出，则需要自己安装，如果用`brew cask`或手动安装失败报错，则看一下`/Library/Extensions`目录是否有`tap.kext`和`tun.kext`两个目录，如果有，则通过以下命令装载：

```bash
sudo kextload /LibraryExtensions/tap.kext
sudo kextload /LibraryExtensions/tun.kext
```

这时再用`kextstat |grep -e tun -e tap`看，估计就有输出了，如果还是没有，则到`System Preferences`-`Security & Privacy`看看是否被禁止了，若是被禁止了，就强行同意即可。

安装好了tuntap和tinc，就可以开始配置，Linux和macOS下基本是一样的，创建一个目录：

```bash
sudo mkdir -p /etc/tinc/netname/hosts
```

其中`netname`是自己随意设定的网络名，一旦设定，所有节点都要使用相同名字，之后在tinc的命令行中也要用到。

在`/etc/tinc/netname`目录下创建`tinc.conf`和`tinc-up`/`tinc-down`，可以参考[linode的文章](https://www.linode.com/docs/networking/vpn/how-to-set-up-tinc-peer-to-peer-vpn/)编写。其中所有节点中必须要至少有一个节点是有公网IP（所有其他节点都能访问到）的，其他节点就都连这个节点进行中转，照tinc的理念，其他节点一旦通过中转建立好连接后，会视情况进行点对点直连或仍然继续通过节点中转。可以有多个节点拥有公网IP并进行中转，其他节点也可以配置连接多个中转节点。

`tinc-up`/`tinc-down`在Linux下和macOS下的命令也许略有不同，比如我的`tinc-up`在Linux下是这样的：

```bash
#!/bin/sh
ip link set $INTERFACE up
ip addr add 192.168.88.3 dev $INTERFACE
ip route add 192.168.88.0/24 dev $INTERFACE
```

在macOS下则是这样的：

```bash
#!/bin/sh
ifconfig $INTERFACE 192.168.88.5 192.168.88.2 mtu 1500 netmask 255.255.255.0
route add -net 192.168.88.5 192.168.88.2 255.255.255.0
```

同样`tinc-down`也要使用平台相应的命令。

然后在`/etc/tinc/netname/hosts`目录下，创建一个与`tinc.conf`文件中`Name`项的值相同的名字的文件，比如`Name = node1`，则创建文件名为`node1`。`node1`的内容主要大概是这样：

```
Address=my.xxx.com   # 公网地址，可以是域名或IP，如果不是中转节点，可以不要这一行
Subnet=192.168.88.2  # 内网地址，可以是一个网段或一个具体IP
```

再之后，通过命令生成密钥：

```bash
sudo tincd -n netname -K4096  
```

这个命令会生成一个RSA公钥和一个私钥，会询问密钥保存的文件路径，其中要公钥需要添加到hosts文件的末尾，可以直接指定hosts文件路径作为公钥文件路径。

最后，把所有节点上的hosts文件都互相交换，存放一个副本到所有其他节点的`/etc/tinc/netname/hosts`目录下，就可以运行tinc daemon命令了：

```bash
sudo tincd -n netname -D -d 3
```

第一次运行，可以先加`-D`参数，让进程放在前台运行，加`-d 3`打印详细的调试日志以供出问题时查看，要杀掉该进程，不推荐直接使用`kill`命令，而是提供了相应的方法：

```bash
sudo tincd -n netname -k
```

这时可以通过`ifconfig`命令查看是否多了一个名字为`netname`的网络连接，IP则是在`tinc-up`设置的。还可以互相ping一下对方IP，没什么问题的话，几个机器应该可以当成在同一个网络里互相访问了，可以把`-D`和`-d 3`参数去掉：

```bash
sudo tincd -n netname
```

还是比较简单的，唯一比较麻烦的是新加一个节点的话，要在所有节点都同步添加一个hosts文件，如果修改了配置，要用命令更新：

```bash
sudo tincd -n netname -kHUP
```

用tinc替换了zerotier体验了一下，感觉不错，要是有个GUI的配置工具以及hosts目录同步功能，就完美了！



