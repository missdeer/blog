---
layout: post
title: "SSR混淆插件Go版移植手记（二）"
categories: Shareware
description: tls1.2_ticket_auth混淆功能完成了
tags: Go GFW shadowsocks
---

虽然Go实现的代码是照着C#版的代码翻译过来了，但是引入了很多问题，经过几天的仔细排查，现在tls1.2_ticket_auth混淆功能终于完成了！稍微记录一点需要注意的点，以便日后翻阅。

原本的[ss-go](https://github.com/shadowsocks/shadowsocks-go)的实现中，在客户端侧接收数据，先[读取指定长度的iv](https://github.com/shadowsocks/shadowsocks-go/blob/master/shadowsocks/conn.go#L119)，接着会[依照buffer的大小读取最多那么多的字节](https://github.com/shadowsocks/shadowsocks-go/blob/master/shadowsocks/conn.go#L137)，然后[解密成同样数量的字节](https://github.com/shadowsocks/shadowsocks-go/blob/master/shadowsocks/conn.go#L139)返回给用户侧socket。在加入混淆的实现中，流程有所变化：

1. 先随便读一段数据，可以是1K、2K、4K等。
2. 调用混淆decode，一般说来第一次decode后会要求send back，把0字节数据encode一下立马发送回给服务端，然后返回，即继续读取数据。
3. 之后再读取的数据被decode后，一般不会再要求send back了，这时跟原版的操作一样了，最开始的几个字节是iv，之后是加密的数据，可以被解密。
4. 解密后的数据长度不一定，可能很短，十几个字节，也可能很长，好几KB，需要自己再分片发给用户侧socket。

混淆decode是个很简单的过程：

1. 每个session（即客户端与服务商的每个tcp连接）维护一个`handshake status`，如果`handshake status`不为`8`，则进行hmac校验，服务端对数据流第`11`个字节开始，总共`22`个字节进行hmac计算，把它计算好的hmac结果前`10`个字节放在数据流的第`33`个字节开始的位置，客户端根据这个信息校验它收到的数据。如果校验通过，则要返回一个标识，要求外面send back（上面第2点）。
2. 如果`handshake status`等于`8`，则按照`3`字节的magic number `0x170303`+`2`字节的数据长度+前面`2`字节指出的长度的有效净荷数据，这种规则把所有有效净荷数据提取出来，合成原始的加密数据。这里要注意网络传输数据分片可能把数据在任意一个位置截断，所以要合包再分包。之后便是上面第3点的过程了。

混淆encode的过程比较繁琐：

1. session最开始的`handshake status`肯定是`0`，这时构建一个伪造的TLS协议头，中间除了长度，SNI信息和hmac结果以及一些随机数字节是动态生成的外，其余的字节都是固定的，只要摆好位置即可。然后把`handshake status`改为`1`。
2. 如果`handshake status`是`1`，如果需要被encode的数据长度大于`0`，就在数据前加入`3`字节的magic number `0x170303`+`2`字节的数据长度，然后保存起来下次有用。如果encode数据长度是`0`，就把前面保存起来的那些数据取出来，前面加上`11`字节固定的协议头+`22`字节的随机数据+`10`字节的hmac结果，然后一起作为被encode后的结果返回。再把`handshake status`改为`8`。
3. 如果`handshake status`是`8`，则把要被encode的数据随机截断成n个小于4KB的包，每个包前面插入`3`字节的magic number `0x170303`+`2`字节的数据长度，最后连接成一块作为encode后的结果返回。

另外，前面提到的所有hmac过程，都使用SHA1算法，使用的key是原版ss协议中的key+每个session分别生成一个`32`字节长的随机数串，经过标准的hmac计算后截取前`10`个字节使用。

基本上就是这个过程。