---
layout: post
author: missdeer
title: "SSR混淆协议Go版移植手记（四）"
categories: Shareware
description: 完成auth_sha1_v4, auth_aes128_md5, auth_aes128_sha1
tags: Go GFW shadowsocks
---

代码几天前就写完了，就是调试不通，昨天晚上偶然在github上看到从[libev版](https://github.com/breakwa11/shadowsocks-libev)分离出来的[obfsplugin](https://github.com/breakwa11/obfsplugin)，都打算用[CGO](https://golang.org/cmd/cgo/)集成到avege去算了，今天上午甚至把编译、链接错误全都改完了，后来想想CGO还是不太好。

后来在看代码时，无意间发现一个问题，得益于我之前把每个字节都应该放什么内容全写在注释里了，突然发现在一个crc32的结果填充到`[]byte`时居然只用到后`2`个字节，而原本是需要全部`4`字节的！修正了这个问题后，代码就能往下跑了，之后是在校验`adler32`时，发现总是把最后`4`个字节的预期校验值也一起计算了，所以总是校验失败。修正后，`auth_sha1_v4`就能基本正常地跑起来了！

`auth_aes128_md5`和`auth_aes128_sha1`用的同一套代码实现，只是在计算hmac时一个用的是MD5算法，另一个用的是SHA1算法，也是几处低级错误。

- 几处`uint16`/`uint32`转`[]byte`时大端小端弄错了；
- 计算`aes128-cbc`加密用的key，要用统一的方法把原始密码字符串转成16字节长的key；
- 有些数据，比如`connection ID`是每个远程服务器有一份的，当时这个概念没搞对，写成每个连接有一份了；
- 预先分配了内存空间，得到解密后数据时却是添加到末尾；

现在总算都调通了，至少使用命令`curl --socks5 127.0.0.1:1080 -vv api.twitter.com`都能得到正确的结果了。但是可能在返回大量数据时仍然存在点问题，需要再仔细审查一下代码。这样就算是把SSR的混淆和协议都移植过来了。

之后的计划是支持UDP、IPv6，再是集成tun2socks的实现。