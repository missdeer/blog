---
layout: post
title: "SSR混淆协议Go版移植手记（五）"
categories: Shareware
description: tls1.2_ticket_auth和auth_sha1_v4基本可以正常工作了
tags: Go GFW shadowsocks 
---

之前写好的tls1.2_ticket_auth在接收到大量数据时会decode出错，后来发现auth_sha1_v4在接收大量数据时最后一块数据时会要等一段时间才能收到。由于tls1.2_ticket_auth的问题在前面那么多天的仔细排查定位后，仍然毫无头绪，我觉得auth_sha1_v4的问题应该会容易一些，就先尝试一下修正这个问题。

昨天终于定位到，avege其实已经从服务端接收到数据了，只是要经过混淆decode，算法decrypt，协议post decrypt三个步骤，然后得到新的数据，长度跟接收到的数据长度可能完全不一样，问题就出在这里了。从被代理程序的角度讲，它比较希望的是得到一个平滑的数据流，所以解决办法也比较简单：把最终的数据放在一块缓存里。

发送给被代理程序的数据每次都是从缓存里读取固定长度，比如4KB。如果缓存是空，则先从服务端读取，再经过混淆decode，算法decrypt，协议post decrypt三个步骤，把得到的新数据放缓存里，最后仍然是从缓存里读数据给被代理程序。其次，返回数据给被代理程序时，另外开一个goroutine继续进行“从服务端读取，混淆decode，算法decrypt，协议post decrypt”这几步操作。还有一些错误处理，比如那个goroutine中如果遇到过error，就把这error记下来，以后再也不再读服务端数据，最后还要把error传递到跟被代理程序交互的那部分逻辑中。

修改后测试结果auth_sha1_v4确实可以一次连续把所有数据都接收了。而且，tls1.2_ticket_auth也能正常工作了，真是意料之外，情理之中啊。

----

昨天随手把连接服务端的逻辑稍微修改了下，不再使用IP地址直接连接，而是使用域名，这样在IPv4/IPv6 dual stack的环境（比如公司里，可能现在家里的路由器上也算是dual stack）中便能享受到happy eyeball的好处了。在公司里简单试用下来，感觉不错。就是得要好好想想DNS proxy部分是否有优化的余地，目前感觉有点慢。