---
layout: post
title: "Raspbian上安装使用华为E8372"
categories: embed
description: 最近情况
tags: Gitea Raspbian USB
---

今天还在树莓派上试了一下之前买的华为E8372这块4G无线路由器。树莓派上运行的系统是Raspbian，直接把E8372插到USB上是没什么反应的，用`lsusb`是能看到有东西：

```shell
Bus 001 Device 012: ID 12d1:1f01 Huawei Technologies Co., Ltd. 
```

大概是这个样子，注意中间那两个16进制数`12d1:1f01`。然后安装几个包：

```shell
sudo apt-get install usb-modeswitch usb-modeswitch-data libusb libusb-dev
```

之后运行命令：

```shell
sudo /usr/sbin/usb_modeswitch -v 12d1 -p 1f01 -M '55534243123456780000000000000a11062000000000000100000000000000'
```

注意，参数`-v`和`-p`就是`lsusb`显示的那两个数字。再用`ifconfig -a`看，应该能看到多了一个interface，比如我之前已经有一个`eth0`了，便会再多一个`eth1`，但这个`eth1`是没有IP地址的，如果再运行`lsusb`，会得到如下结果：

```shell
Bus 001 Device 012: ID 12d1:14db Huawei Technologies Co., Ltd. 
```

那两个数字已经变了，这时需要再运行命令：

```shell
sudo /bin/bash -c 'modprobe option && echo 12d1 14db > /sys/bus/usb-serial/drivers/option1/new_id'
```

把那两个数字写到那个文件中，再用`ifconfig -a`看，`eth1`便已经被分配了一个IP地址，已经可以用这个interface上网了。

如果重新拔插了E8372，便可能需要重新运行那两条命令来得到一个新interface并分配IP，为了方便可以通过udev监测E8372插入动作。创建一个文件`/etc/udev/rules.d/70-huawei_e8372.rules`，写入内容：

```
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="1f01", RUN+="/usr/sbin/usb_modeswitch -v 12d1 -p 1f01 -M '55534243123456780000000000000a11062000000000000100000000000000'" 
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="1f01", RUN+="/bin/bash -c 'modprobe option && echo 12d1 14db > /sys/bus/usb-serial/drivers/option1/new_id'"
```

然后运行命令：

```shell
sudo udevadm control --reload-rules
```

再重启系统，以后E8372插入时便会自动执行以上两条命令了。

----

因为我也不用手机看视频，现在手机流量处于用不完的状态，9.9元买入的日租卡的流量更是一天一天的被浪费，急缺一个能每天用掉近500M流量的好点子啊。

----

不看不知道，一看吓一跳。今天在路由器上偶然看到貌似被“肉鸡”了！有外面不认识的IP通过ssh连到了路由器上，居然在sshd_config里设置成禁止root登录和禁止密码登录都没用！看了一下netstat，似乎是因为redis被利用了，才发现redis居然是运行在`0.0.0.0`上。于是先把redis绑定到`127.0.0.1`，再iptables把从`ppp0`进来的连22端口的连接全部drop掉，终于感觉好一点了。

------

昨天在Golang实战群看到 @[lunny](https://github.com/lunny) 提到[Gitea](https://github.com/go-gitea/gitea)，这是一个从[Gogs](https://github.com/gogits/gogs) fork来的自助git服务平台，以前也试过[Gogs](https://github.com/gogits/gogs)，那时候bug非常多，基本上经不起日常使用，于是很久都没关注了。而[Gitea](https://github.com/go-gitea/gitea)则是另一拨人因为开发理念上跟[Gogs](https://github.com/gogits/gogs)的原创者 @[Unknwon](https://github.com/Unknwon) 有比较大的分歧从而fork出来的，现在已经正式发布到1.0.1版本了，于是我在家里的树莓派上装了一个试试。过程非常简单，下载预编译好的可执行文件，在命令行运行`./gitea-1.0.1-arm7 web`便会在`3000`端口开一个http服务，然后用浏览器打开`http://ip:3000/`设置一下路径之类的便能使用了。

我在开始使用时，ssh方式不能正常工作，push不了。在[@lunny](https://github.com/lunny)的远程协助下，最后终于定位到，因为我是用平常登录使用的普通账号运行的，在`$HOME/.ssh/authorized_keys`中前面的公钥拦截了本该让[Gitea](https://github.com/go-gitea/gitea)被调起的命令，所以就不工作了。比较干净的解决办法是另外创建一个新的账号，比如git，用新账号运行服务，也把公钥写到新账号所在的`$HOME/.ssh/authorized_keys`中即可。

----

SSR的混淆和协议移植到Go版本代码都写完了，但是测试发现tls1.2_ticket_auth在从服务端接收大量数据时，会出现decode出错误数据的情况，看了几遍代码，还是没发现异常。然后就拖延症犯了。

