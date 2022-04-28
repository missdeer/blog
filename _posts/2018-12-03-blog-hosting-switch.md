---
layout: post
image: https://img.peapix.com/3323382884592456783_320.jpg
author: missdeer
title: "更换blog托管"
categories: blog
description: 更换blog托管
tags: 
  - blog
  - github pages
  - coding pages
---

去年把blog[托管到了coding pages上](../../../2017/08/host-by-coding-pages/)，以为可以为大陆提供更好的访问速度，但实际上效果似乎并没有想像的那么好，coding pages貌似是为了规避大陆网页要求备案，把大陆访问IP引导到了香港的主机上，网络一旦出了国，速度就会降很多，另一点是免费的coding pages要求在页面上添加他们的声明信息，虽然就算他们不要求，我也会在页脚处添加各种感谢声明，但强行要求就让我心里总有点疙瘩。

这两天偶然知道开源CDN服务[jsDelivr](https://www.jsdelivr.com/)可以直接加速[github](https://github.com/)上的资源，比如我的blog仓库是`https://github.com/missdeer/blog`，使用`gh-pages`branch，那么如果有一个文件路径是`/js/main.js`，用[jsDelivr](https://www.jsdelivr.com/)则通过URL`https://blogassets.ismisv.com/js/main.js`访问，就可以获得CDN加速的效果，其中`https://fastly.jsdelivr.net/`是固定的域名，`gh`表示`github`，`missdeer/blog`表示我的仓库，`gh-pages`表示所在branch，之后便是文件路径。

在中国大陆，[jsDelivr](https://www.jsdelivr.com/)是通过`QUANTIL`这家CDN（据说`QUANTIL`是网宿参股公司，`QUANTIL`国内节点为网宿实际运营）实现的，实测下来速度非常好，而且如果是js或css文件，可以通过添加`.min`自动获得紧缩版本，比如`https://blogassets.ismisv.com/js/main.min.js`，不用自己另外单独提供一份。

我把blog上几乎所有除了HTML外的静态资源，比如js，css，图片，字体文件等，全部替换成[jsDelivr](https://www.jsdelivr.com/)加速了。blog原本在coding pages上是用一个二级域名`https://blog.minidump.info`的，切换回github 
pages后不再用这二级域名了，而是顶级域名下加一级路径`https://minidump.info/blog/`，可以直接使用github 
pages的SSL证书。原来的二级域名就在linode上用nginx加了个301跳转到新地址。

最后，是修正leancloud上的评论记录，把原本在`https://blog.minidump.info/`上的评论全部转移到`https://minidump.info/blog/`上了。

所以现在时间可能主要花在blog域名的DNS解析(cloudflare家在大陆似乎并不好)，301跳转，HTML文件下载这三部分了，其他上了CDN的静态资源应该比以前会快很多吧。

另外有一个问题，更新了blog，新增/修改的内容不能立即同步到`https://blogassets.ismisv.com/`这个路径下，要把`gh-pages`换成git commit的hash id，可能要过2天才会同步，这点略显繁琐。