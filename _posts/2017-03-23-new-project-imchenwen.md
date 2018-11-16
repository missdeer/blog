---
layout: post
title: "新坑：imchenwen，用外部播放器观看在线视频"
categories: Shareware
description: 用外部视频播放器观看在线视频
tags: Qt Go imchenwen
---

不知道怎么想的，突然开了个新坑，因为[bilibili mac client](https://github.com/typcn/bilibili-mac-client)并不能好好地工作，所以自己写一个也挺好玩的。

目前已经完成了基本的功能，可以通过右键菜单调起外部的播放器观看几大主流视频网站，可以自行设置使用的播放器路径及参数，也可以自行选择要观看的视频质量。

![截图](https://pbs.twimg.com/media/C7aCzxgU8AEsJ1k.png:large)

目前存在的一些问题：

- VIP视频还没支持。
- 分成几段的在线视频在段与段切换时会有停顿，可能需要自己做个传输功能实现无缝切换。
- 爱奇艺的视频分成多段后，后面几段的地址没多久就会失效，可能也需要自己做的传输功能及时下载。
- 还在犹豫是否自己实现一个视频播放功能。
- 用的Qt WebEngine不但体积大，而且功能并不完善，比如不支持输入法，顺便可能还存在一些bug。这个可以忍。

----

多说终于要关闭了，换Disqus了，貌似这货在大陆不是被墙就是太慢，还好我的blog也没几个评论，就凑合着吧。