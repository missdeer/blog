---
image: https://cdn.jsdelivr.net/gh/missdeer/blog@master/media/2021-02-23/http3.png
layout: post
author: missdeer
featured: false
title: "本站开启HTTP3/QUIC支持"
categories: blog
description: "本站开启HTTP3/QUIC支持"
tags: http3 quic
---
得益于Cloudflare CDN的强力支持，偶然发现本站已经支持HTTP3/QUIC了，初步使用体验下来，比传统的HTTP1.1和HTTP2协议要快不少，值得大力宣传和使用。

鉴于HTTP3/QUIC目前尚未大规模普及，各大主流浏览器默认也并没有打开相关选项，用户在浏览网页时默认仍然使用HTTP1.1和HTTP2协议，需要手动打开选项使浏览器在发现网站支持HTTP3/QUIC时尝试使用该协议。

Firefox 75及以上版本已支持HTTP3/QUIC，启用方法如下图所示，在地址栏输入 `about:config`，配置 `network.http.http3.enabled = true`：

![firefox-h3-about-config](https://cdn.jsdelivr.net/gh/missdeer/blog@master/media/2021-02-23/firefox-h3-about-config.png)

开启该选项后，再重新打开本网站浏览，通过`Web开发者`功能可以看到，已经使用HTTP3协议了：

![firefox-network](https://cdn.jsdelivr.net/gh/missdeer/blog@master/media/2021-02-23/firefox-network.png)

Chrome 83 及以上版本支持 HTTP/3，使用命令行增加如下启动参数：

```
$ ./chrome --enable-quic --quic-version=h3-27
```

Windows系统（将$USER替换为你的Windows登录账号）：

```
cd C:\Users\$USER\AppData\Local\Google\Chrome\Application
chrome.exe --enable-quic --quic-version=h3-27
```

macOS系统：

```
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --enable-quic --quic-version=h3-27
```

Microsoft Edge （基于Chromium） 与 Chrome 同步支持，例如在 macOS 中运行 Edge：

```
/Applications/Microsoft\ Edge.app//Contents/MacOS/Microsoft\ Edge --enable-quic --quic-version=h3-27
```