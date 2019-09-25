---
layout: post
image: https://blogimg.minidump.info/2014-08-19-https-supported.md
author: missdeer
title: "支持https"
categories: Startup
description: yiili支持https了
tags: https ssl 
---
昨天找SSL代购买了个支持泛域名的SSL证书，现在[Yiili](https://yii.li)就支持https了，我在nginx上加了个重定向，把所有http的请求都指向https了。

周末给Yiili加了新的渲染后端，原来是用了Markdown，感觉这种编辑方式对程序类的比较适合，其他类型的用户群体并不特别方便。这次加了Readability和Embed.ly的卡片嵌入，其中Readability是用了python版的[readability-lxml](https://github.com/buriy/python-readability)，目前看来效果至少够用，可以看看[这个例子](https://dev.yii.li/post/8)。而Embed.ly支持的那些服务商，很多对天朝来说都是被墙的，比如Twitter，Facebook和Google plus。不过因为经过Embed.ly服务器的中转，可以隐约绕过GFW，这也是我要上https的原因，因为URL中带敏感词的还是会被干扰，https的URL参数就探测不到了，可以看看[这个](https://dev.yii.li/post/9)，[这个](https://dev.yii.li/post/11)和[这个](https://dev.yii.li/post/10)，也许还是比较困难，我估计是embed.ly的CDN在天朝不给力。本来还学v2ex可以嵌入优酷视频的，但是它没提供https的服务，所以上了https后只能废掉了，叹气。

完成了这些，现在可以开始找内容大量转帖先了，先吸引些流量再说。
