---
layout: post
image: https://img.peapix.com/ef6816bb660d43a0b13334df4dddfb18_320.jpg
author: missdeer
title: "CoreDNS搭建无污染DNS"
categories: gfw
description: 使用CoreDNS搭建无污染DNS服务
tags: GFW DNS CoreDNS
---

我之前整理过在国内搭建无污染DNS的[一些方法](../../../2016/05/dns-resolve/)，github上各种轮子也层出不穷，但基本原理几乎不变。自从半年多前开始用[CoreDNS](https://github.com/coredns/coredns)，我觉得可以不用dnsmasq/[overture](https://github.com/shawn1m/overture)/chinadns这些轮子了，CoreDNS完全符合我的需求：

* 无污染
* 国内CDN友好
* 跨平台，支持多种CPU、操作系统

CoreDNS的来头不小，它的[作者](https://github.com/miekg)是最好的开源[DNS package](https://github.com/miekg/dns)的作者，CoreDNS底层也使用了这个package。大名鼎鼎的k8s使用CoreDNS进行服务发现。CoreDNS基本沿用了[Caddy](https://caddyserver.com/)的插件架构，所以CoreDNS的配置文件的语法跟Caddy的配置文件语法相同。

一个最简单的配置文件可以是这样：

```
.:53{
    forward . 8.8.8.8
    log
    health
}
```

将配置保存为文件`Corefile`，运行命令`sudo coredns -conf Corefile`，即可在本地同时监听TCP和UDP 53端口，将所有UDP查询请求转发到`8.8.8.8`再返回，可以通过`dig @::1 -p 53 twitter.com`进行测试。

但是这个配置文件在国内几乎是没啥用的，原因自然是`8.8.8.8`乃老大哥重点关注对象，直接访问得到的结果都是二手信息。一个好一点的方案是使用非标准端口，比如：

```
.:53{
    forward . 208.67.222.222:443
    log
    health
}
```

`forward`插件支持多个上游服务器以实现简单的负载均衡：

```
.:53{
    forward . 208.67.222.222:443 208.67.222.222:5353 208.67.220.220:443 208.67.220.220:5353
    log
    health
}
```

大陆的网络环境非常复杂，UDP非标准端口也只在某些地区某些运营商有用，现在比较好的一个选择是DoT，即DNS over TLS，知名的支持DoT的公共DNS服务有Quad9的`9.9.9.9`，Google的`8.8.8.8`以及Cloudflare的`1.1.1.1`，可以这么使用：

```
.:53{
    forward . 127.0.0.1:5301 127.0.0.1:5302 127.0.0.1:5303
    log
    health
}
.:5301 {
   forward . tls://9.9.9.9 {
       tls_servername dns.quad9.net
   }
   cache
}
.:5302 {
    forward . tls://1.1.1.1 tls://1.0.0.1 {
        tls_servername 1dot1dot1dot1.cloudflare-dns.com
    }
    cache
}
.:5303 {
    forward . tls://8.8.8.8 tls://8.8.4.4 {
        tls_servername dns.google
    }
    cache
}
```

这样除了老大哥把连接reset，基本可以得到正确的DNS解析结果。

另一个问题是国内CDN友好，我一直以来的做法是使用[FelixOnMars的大陆区域名列表](https://github.com/felixonmars/dnsmasq-china-list)过滤。这个列表是给dnsmasq用的，经过转换可以给CoreDNS用，这利用了CoreDNS的两个插件来实现，分别是`forward`和`proxy`，这两个插件的功能非常相似，都是将DNS解析请求发给上游DNS server，再将结果取回返回给客户端。为了实现分流解析，可以将所有请求都通过`forward`转发到无污染上游解析，将大陆区域名列表加到异常列表，再把剩下的所有请求（其实就是异常列表中的域名）通过`proxy`转发到国内（最好是当前ISP的）DNS server，比如：

```
.:53{
    forward . 127.0.0.1:5301 127.0.0.1:5302 127.0.0.1:5303 {
        except www.taobao.com
    }
    proxy . 116.228.111.118 180.168.255.18
    log
    health
}
.:5301 {
   forward . tls://9.9.9.9 {
       tls_servername dns.quad9.net
   }
   cache
}
.:5302 {
    forward . tls://1.1.1.1 tls://1.0.0.1 {
        tls_servername 1dot1dot1dot1.cloudflare-dns.com
    }
    cache
}
.:5303 {
    forward . tls://8.8.8.8 tls://8.8.4.4 {
        tls_servername dns.google
    }
    cache
}
```

这里`except www.taobao.com`表示`www.taobao.com`这个域名不要通过`forward`解析，后面可以跟多个域名，于是这些域名会掉到下面的`proxy`插件进行解析，而`116.228.111.118`和`180.168.255.18`则是我的ISP提供的DNS服务器，可以得到最好的CDN友好的结果。

这时就可以用上[FelixOnMars的大陆区域名列表](https://github.com/felixonmars/dnsmasq-china-list)了，用以下命令可以得到所有域名连接而成的长字符串，放在`except`标识符后面:

```
china=`curl https://cdn.jsdelivr.net/gh/felixonmars/dnsmasq-china-list/accelerated-domains.china.conf -s | while read line; do awk -F '/' '{print $2}' | grep -v '#' ; done |  paste -sd " " -`
echo "  except $china " >> Corefile
```

FelixOnMars同时还提供了Google和Apple的域名列表，这在某些地区某些ISP可以得到国内镜像的IP，所以最后可以写一个这样的shell脚本用于生成Corefile：

{% gist 5c7c82b5b67f8afb41cfd43d51b82c2d %}

我把这个脚本放在gist上，并做了个短网址，于是可以这样生成Corefile：

```bash
curl -s -L git.io/corefile | bash
```

到此为止，就已经得到国内CDN友好的无污染DNS解析服务了。

我还想得到更多，比如去广告！github上有非常多的列表，包括广告和有害软件等等，CoreDNS官方尚未提供一个block插件，好在已经有一些非官方的实现，比如[block](https://github.com/missdeer/block/)，可以用如下的方式使用：

```
.:53{
    block https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
    block https://mirror1.malwaredomains.com/files/justdomains
    block https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
    forward . 127.0.0.1:5301 127.0.0.1:5302 127.0.0.1:5303 {
        except www.taobao.com
    }
    proxy . 116.228.111.118 180.168.255.18
    log
    health
}
```

非常浅显易懂。如果遇到的请求域名是在列表中，则会返回`NXDOMAIN`。

最后一个问题，由于`proxy`插件和`block`插件都不是官方内置插件，从CoreDNS官方下载页下载的可执行程序并不包括这两个插件，所以需要自己编译CoreDNS。

编译CoreDNS并不复杂：

```
git clone https://github.com/coredns/coredns.git
cd coredns
make
```

CoreDNS使用了go modules机制，所以在`make`过程中会自动下载依赖的package。其中一些package是放在诸如`golang.org/x/`的路径下的，所以需要自备梯子，可以全局翻，也可以通过`HTTP_PROXY`环境变量指定，或者使用国内的一些镜像（如果你信得过的话）通过`GOPROXY`环境变量指定。

如果要加入以上两个插件，则在`make`前，要修改`plugin.cfg`文件，加入以下两行：

```
block:github.com/missdeer/block
proxy:github.com/coredns/proxy
```

再`make`，就会把这两个插件编译进去。如果发现没有编译进去，可以先执行一下`go generate coredns.go`再`make`。

如果要给其他平台交叉编译CoreDNS，需要先以当前平台为参数`make`一次，再以目标平台为参数进行`make`，因为第一次`make`时会调用`go generate`跑两个程序，如果不是当前平台的可执行文件是跑不起来的。

最后，我把这个编译过程放到[github](https://github.com/missdeer/coredns_custom_build)上了，用`appveyor`服务编译出[各个目标平台的CoreDNS](https://ci.appveyor.com/project/missdeer/coredns-custom-build)。