---
layout: post
title: "把blog托管到Coding Pages"
categories: blog
description: "把blog托管到Coding Pages"
tags: blog
---

自从重新开始写blog，都是托管在github pages上，然后通过cloudflare中转以及https证书。这一套方案总的说来工作得挺好的，但是，万事就怕但是，在大陆cloudflare的服务并不是特别稳定。后来发现Coding.net也提供Pages服务了，还集成了Let's Encrypt的证书服务，于是就迁过去了。

迁过去有一些事要解决：

1. 在Coding.net上创建一个新的仓库，添加一个remote：`git remote add coding git@git.coding.net:missdeer/blog.git`。
2. 因为Coding pages支持从master或coding-pages两种branch部署pages，所以直接把gh-pages推送上去即可：`git push coding gh-pages:master`。
3. 修改自定义域名的DNS设置，CNAME到pages.coding.me。
4. 在页面中添加Coding Pages的声明。
5. 到Coding Pages的设置页添加自定义域名，它不像github pages那样读根目录下的CNAME文件。
6. 为自定义域名申请https证书以及申请去除跳转广告。

大功告成。目前看来Coding Pages在全球都有部署，在大陆也有，大大提升了在大陆的访问速度，只不过在github上的部署就废了。

网上有不少文章介绍coding pages和github pages双线部署，在我看来根本没必要，本来一个中文blog就没几个海外访问者，而且Coding pages在海外访问并不慢。