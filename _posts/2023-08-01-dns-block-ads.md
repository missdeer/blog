---
image: https://blogassets.ismisv.com/media/2023-08-01/noads.png
layout: post
author: missdeer
featured: false
title: "修改DNS去广告"
categories: network
description: 修改DNS去广告
tags: DNS CoreDNS
---

以前也尝试过在DNS上做手脚拦截广告，但因为误杀太多以及漏网之鱼太多，觉得还不如不折腾呢。

最近偶然发现了[一组列表](https://github.com/missdeer/blocklist)，又尝试了一番，发现效果挺不错的，手机开屏广告绝大多数不见，浏览网页时Google Ads也基本没有了，真是让我喜出望外。所以以前效果不好的原因只是因为使用的黑名单列表不好而已。

我是在路由器上的[CoreDNS](https://github.com/missdeer/coredns_custom_build)使用[ads](https://github.com/missdeer/ads)插件设置拦截的，所有接入的设备都可以享受到这个效果。用到3组黑名单源，分别是[Anti-ad](https://anti-ad.net)，[AdGuard](https://github.com/AdguardTeam)和[EasyList](https://github.com/easylist/easylist/)，然后自己写了点代码将列表规整了一下，转成[hosts文件的格式](https://github.com/missdeer/blocklist)后合并为一个文件，[ads](https://github.com/missdeer/ads)插件可以直接通过http协议加载hosts格式的文件。CoreDNS的配置文件增加ads就行了：

```js
#blocklist domains.txt
ads {
    blacklist https://cdn.jsdelivr.net/gh/missdeer/blocklist@master/convert/alldomains.txt
    nxdomain
}
```





