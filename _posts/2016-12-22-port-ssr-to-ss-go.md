---
layout: post
title: "SSR混淆插件Go版移植手记（一）"
categories: Shareware
description: 将SSR的混淆和协议插件移植到Go的实现
tags: Go GFW shadowsocks
---

这几天断断续续地移植着SSR的一个混淆插件tls1.2_ticket_auth，至今仍然没能正常工作起来，忧郁啊。稍微记录一点读[ss-go](https://github.com/shadowsocks/shadowsocks-go)和[ssr-csharp](https://github.com/breakwa11/shadowsocks-csharp)/[ssr-libev](https://github.com/breakwa11/shadowsocks-libev)的代码所得，以便日后翻阅。

本身ss协议的定义已经有公开的[文档](http://shadowsocks.org/en/spec/protocol.html)了，很简单，每个客户端连接服务端时，最开始是一串随机数iv，长度依不同的加密算法而不同，加密算法本身以及算法使用的key而是由用户自己保证客户端和服务端一致。之后是1个字节的目标地址类型，目前有3种，分别是IPv4，IPv6和域名，再之后是分别是4字节，16字节和255字节长的目标地址，接着2字节长的目标端口，然后才是真正的数据，这数据是经过加密的。

从这个协议定义便可以看出，iv长度其实只有8字节和16字节两种，所以很容易猜出第9字节或第17字节便是地址类型，从第10字节或第18字节开始便是目标地址，如果GFW想要干扰一下，真的不困难。

SSR便是试图改善这种情况。首先，它会将待加密的数据先处理一遍，这个过程我还没时间看，不知道它具体干了些什么，然后把处理过的数据像原版协议那样加密，接着，把iv添加到头部，跟加密后的数据一起再混淆一遍，最后才发送出去。就我读代码观察下来的结论，tls1.2_ticket_auth插件就是试图把数据流伪装成一个常规的https流，让GFW和运营商放过它。

原版SS曾经实现过一个One Time Auth功能，它所做的其实是SSR在协议插件中做的事。OTA先在目标地址类型的那个字节中置1位标识，然后把地址类型，地址，端口这三部分一起做一次HMAC-SHA1，而HMAC-SHA1计算时用的key是本次连接用的iv加上用户设置的加密算法用的key，HMAC-SHA1的结果截取前10字节，添加到端口后面，4部分一起作为头部。后面发送的加密数据部分，前面先加2个字节长的数据长度，10个字节的HMAC-SHA1结果，这里的HMAC-SHA1使用的key是本次连接用的iv加上一个递增的ID。但我还没想明白，它怎么处理分包粘包的问题，似乎它并没有刻意去处理。

在[ss-go](https://github.com/shadowsocks/shadowsocks-go)中有一个[leaky buffer](https://github.com/shadowsocks/shadowsocks-go/blob/master/shadowsocks/leakybuf.go)的实现，之前我一直没想过这东西具体是干什么的，只当是一个缓存。后来再看觉得是[leaky bucket](https://en.wikipedia.org/wiki/Leaky_bucket)的一个实现。众所周知leaky bucket是为了限流而设计的，但我看leaky buffer的实现虽然也能起到限流的作用，比如创建它的实例时需要提供两个参数，一个是buffer最大数量，另一个是每个buffer的大小，每个ss连接发起时会从leaky buffer那取两个buffer分别分给send buffer和receive buffer，如果buffer最大数量已经被消耗完，就得等其他的连接释放buffer。从这个角度看，和semaphore的功能差不多嘛，都是限制一定上限的资源使用，如果被用完了就等其他用户释放资源。我在某个技术群里提出了这个疑问，有人说，leaky bucket流控是有预期的，流量什么时候放，semaphore没预期，得等同步。但我觉得他说的虽然有点道理，在ss-go这个场景中，换semaphore完全可以达到一样的效果啊。