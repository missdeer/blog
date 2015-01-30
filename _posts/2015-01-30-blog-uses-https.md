---
layout: post
title: "Blog开启https支持并强制使用"
categories: life
description: Blog开启https支持并强制使用
tags: blog jekyll https
---
上周在cloudflare又新建了个账号，记得很多年前我有个账号的，不过忘了密码也忘了注册邮箱，只好再新建个。然后用free plan加了两个域名，其中一个就是现在blog在用的minidump.info，cloudflare除了CDN，还能提供SSL，这点非常赞，于是就加上了。昨天晚上看到有人说自己在github pages上的blog因为敏感词被GFW过滤而reset了某个页面，于是我想不如把整站强制使用https算了。说干就干，因为我用的是Jekyll，只要在_layout的模板中加几行Javascript代码就可以搞定：

```js
var ishttps = 'https:' == document.location.protocol ? true: false;
if(ishttps == false){
    location.href = location.href.replace("http://", "https://");
}
```

然后发现多说不能默认加载了，因为浏览器安全级别高一点就会把https的页面中使用的http js默认禁掉，所以也需要改成使用https的嵌入脚本。

最后还是多说的问题，貌似多说把同一个host:port/URI下的https和http当成不同的URL处理，所以原来在http下的评论全不能显示了，有点小忧伤，不过还好我这没几条评论。
