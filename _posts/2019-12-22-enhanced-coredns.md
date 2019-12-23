---

image: https://blogimg.minidump.info/2019-12-22-enhanced-coredns.md
layout: post
author: missdeer
featured: true
title: "增强版CoreDNS，上网更科学"
categories: gfw
description: 增强版CoreDNS，上网更科学
tags: GFW DNS CoreDNS

---

使用CoreDNS有不短的时间了，之前也通过自己编译[修改版CoreDNS](https://github.com/missdeer/coredns_custom_build)来[解决DNS污染的问题](../../../2019/07/coredns-no-dns-poisoning/)，不过后来因为没解决好go module依赖的问题，在官方CoreDNS某次commit后修改版就编译不过了，这样持续了一段时间，直到前几天，我又偶然尝试修改了一番，终于又可以编译过了，于是动了继续增强CoreDNS功能的念头，经过几天的尝试，目前有点小成果。

增强版CoreDNS做了这些事情：

1. 修改官方[forward插件](https://github.com/coredns/coredns/tree/master/plugin/forward)的except列表查找算法。官方实现是顺序遍历slice，在slice比较小（比如作者说的不要多于16个元素）的时候是能工作得很好的，但是我把整个[中国大陆区域名列表](https://github.com/felixonmars/dnsmasq-china-list/blob/master/accelerated-domains.china.conf)都加进来了，有7万多个域名，虽然也能工作，但强迫症表示不能忍。于是我改成了用map实现，时间复杂度从线性变成了常量。虽然CoreDNS的作者说官方的实现比较算法做了更多的事，但我粗略地脑补了一下实际使用场景，感觉我的简单实现目前看来是够用了。
2. 加入官方[proxy插件](https://github.com/coredns/proxy)。这个在之前的文章里提到过，只是为了实现域名分流解析而已，现在修正了编译问题。
3. 加入官方[fallback插件](https://github.com/coredns/fallback)。这个插件有一段时间没更新，已经不能直接编译通过了，需要修改的地方并不多，主要就是import的package路径问题，proxy插件从builtin变external，caddy从个人名下移到组织名下。原本是打算做个为某批域名的解析做个fail over，但实际使用下来发现似乎并不起效果。
4. 加入第三方[ads插件](https://github.com/c-mueller/ads)。这个插件是我偶然看到实现得比较好，功能比较完善，而且维护也比较积极的去广告插件。
5. 加入半官方[redisc插件](https://github.com/miekg/redis)。说是半官方是因为这个插件是CoreDNS的作者开发，但没加到CoreDNS的组织名下。我的规划里家里有2台机器跑CoreDNS，这样可以共享缓存了。
6. 自制[bogus插件](https://github.com/missdeer/bogus)。写这个插件的原因是看到肥猫大大收集的[bogus列表](https://github.com/felixonmars/dnsmasq-china-list/blob/master/bogus-nxdomain.china.conf)，既然有这个列表我就想用上，后来想想似乎我这十来年来也只看到过一两次，有点不那么刚需。
7. 自制[ipset插件](https://github.com/missdeer/ipset)。这个插件跟dnsmasq中的ipset功能比较类似，可以把指定的域名解析结果加到ipset中。原因自然是可以通过iptables进行流量自动分流，目前看来效果不错，对我来说特别实用。我的应用场景中，流量被分成三股：
   
8. 1). 大陆区的主机，直连；
   2). 海外的，通过ss-redir走机场线路；
   3). 某内网的，通过[nebula](https://github.comslackhq/nebula)连通，再通过[goproxy](https:/github.com/snail007/goproxy)建了DNS和socks5/http-connect代理，在本地则通过ipset/iptables分流[redsocks](https://github.com/darkk/redsocks)重向到代理中。