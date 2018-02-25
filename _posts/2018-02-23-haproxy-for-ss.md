---
layout: post
title: "HAProxy for SS(R)"
categories: gfw
description: "HAProxy for SS(R)"
tags: GFW shadowsocks HAProxy
---

昨天在喵帕斯tg群里看到一张HAProxy的截图，经过了解，原来是梅林固件自带的，真是不错的想法。

想当初，我为了实现$$的load balance，不惜花费大量的时间和精力，自己用Go写了个[客户端](../../../../2015/11/avege-works-initially/)，结果后来喵帕斯全面开启多用户单端口，而我的程序在带参数的混淆和协议上实现有问题，于是换回用libev版了。用libev版唯一的缺点就是线路变动（比如偶发性down掉，永久换IP，永久移除等等）时，需要手动去切换一下。虽然喵帕斯同时提供了几十条线路，却压根没发挥作用，如果线路稳定倒也好说，但是昨天发现已经用了好长一段时间的线路突然变得时断时续了，真是纠结啊！

好在现在发现了HAProxy这个方案，立即上手试试。我是在Banana Pi R1上部署的，先从官网下载HAProxy源代码，解压并编译：

```bash
wget http://www.haproxy.org/download/1.8/src/haproxy-1.8.4.tar.gz
tar xzvf haproxy-1.8.4.tar.gz
cd haproxy-1.8.4
make linux2628
```

这样就能得到一个可执行文件`haproxy`，然后编写一个配置文件：

```
global 
    daemon  
    maxconn 10240 
    pidfile /home/pi/avege/haproxy.pid 

defaults 
    mode tcp
    balance roundrobin
    timeout connect 10000ms  
    timeout client 50000ms  
    timeout server 50000ms  
    log 127.0.0.1 local0 err

listen admin_stats  
    bind 0.0.0.0:8099
    mode http
    option httplog
    maxconn 10  
    stats refresh 30s
    stats uri /stats  

frontend ssr-in 
    bind *:58543  
    default_backend miaops
	
backend miaops
    option log-health-checks
    default-server inter 15s fall 3 rise 2
    server cn-1 cn-1.node.com:54321 check
    server hk-1 hk-1.node.com:54321 check
    server us-1 us-1.node.com:54321 check
    server tw-1 tw-1.node.com:54321 check
    server ru-1 ru-1.node.com:54321 check
    server jp-1 jp-1.node.com:54321 check
```

最后就是$$连接服务器的地址和端口改成本地HAProxy开的那个端口即可：`127.0.0.1:58543`。

大体上就是这样的，HAProxy会给后端服务器做健康检查，load balance时会跳过down掉的服务器。据我简单的尝试发现，似乎健康检查的参数设置能显著影响$$的效果，现在的设置肯定不是最佳的，但我也没什么经验继续调优。现在的work flow就是这样：

![work flow - https://www.plantuml.com/plantuml/svg/UDfjqh5Emp0G1k3TJ-6H3f58M_P2zmuL6-hWsYTYufoZyxc5ZQVXmNWIZgOf8OaKATRt_v5-IzaaDiIv2KgbscDho3GQeuETQU0n-5VK5f211d5bq9t9CmDgfWo3Y3q7U8haWFOnezj6GY1TFintdYjlQuIKT3bVsCOGIH-3iRLIEvcbJTi6RmtxYAcJb2Zu8vpqYvAZlfpLeSigqr9y_xWMWKv0fVGi5cLVwNGfokUnhaHp6kjQbF9ONUGamVVdbpp_8nH_QmiK7SxNHN4Rhswt4EnNNz-NNhVzZ-xk5xqkPtKr_NmzfT_LKqMbDe1EVeiVECc-cG00](../../../media/2018-02-23/haproxy-workflow.svg)

可以通过浏览器打开`http://haproxy-ip/stats`查看HAProxy的运行状况：

![HAProxy stats](../../../media/2018-02-23/haproxy-stats.png)

就这样先试用一段时间看看效果再说。

----

2.25 update:

不少网站/app会根据你所用的IP来做出一些对应的变化，比如Google会跳转到对应的国别后缀，Telegram在登录时会刷新出对应的电话国际区号，所以HAProxy的配置中一组后端只配置同一国家的线路为好，上面的stats截图中我就只配置了jp的线路。