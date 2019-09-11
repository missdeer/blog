---
layout: post
author: missdeer
title: "Let's Encrypt注意事项"
categories: Cryptography
description: 使用Let's Encrypt遇到点问题
tags: https
---

我从几个月前开始用[acme.sh](https://github.com/Neilpang/acme.sh)来自动签发Let's Encrypt的免费证书，一两个月后，发现它没有renew成功，手动renew发现每次都是报错：

```
Challenge error: {"type":"urn:acme:error:malformed","detail":"Unable to update challenge :: response does not complete challenge","status": 400}
```

在网上随便搜了搜并没有发现有用的信息，然后给[acme.sh](https://github.com/Neilpang/acme.sh)开了个[issue](https://github.com/Neilpang/acme.sh/issues/780)，照作者的说法用了DNS模式手动签发的证书不会自动renew，要用DNS API自动模式重新签发一次：

```shell
PROVIDER=cloudflare LEXICON_CLOUDFLARE_USERNAME=me@minidump.info LEXICON_CLOUDFLARE_TOKEN=11223344556677889900aabbccddeeff acme.sh --issue -d sh.yii.li -d pi.yii.li --dns dns_lexicon
```

如此就可以了。

----

对于开了80端口的，有web root的情况下，比如国外的VPS，可以不用DNS模式，可以省掉DNS那里一些看起来乱七八糟的TXT记录。但是对于像家庭宽带环境中只开443端口的情况，必须要DNS才能验证域名所有权，国内的一些主机提供商比如阿里云劫持了80端口的入流量，如果域名没有备案就会被拦截，于是也只能用DNS模式签发证书。