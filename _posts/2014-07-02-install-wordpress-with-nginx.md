---
layout: post
author: missdeer
title: "Nginx上安装Wordpress"
categories: Software
description: Nginx上安装Wordpress遇到的问题
tags: nginx wordpress
---
自从知道nginx后，就再也不愿意用Apache了，总觉得Apache配置复杂、体积笨重、运行缓慢，当然这些只是我的无根据臆想。原本用nginx只是用来做静态站，做反向代理，今天zhangh说想要个Wordpress做产品展示页面，于是只好弄一下。顺便感叹一下他的执行力。

MiaoCoffee当时选空间从国外转回到国内的阿里云后，zhangh随手就把系统装成了Ubuntu 12.04，这是我之后一直耿耿于怀的事，我很喜欢用CentOS当服务器，当然这其实影响不大。翻了一下网上Nginx上装Wordpress的文章，都是说自己编译一份带fpm的php，于是我也开始这么搞了。又遇到一个槽点，php.net上下载用中国的镜像居然没速度，下了n次没下下来，换成日本的镜像有1MB多的速度，跟吃了个苍蝇一样。

好不容易下载下来了，看了一眼系统中的gcc版本，4.6.3，勉强可用吧，开始configure再make，要装libxml2-dev先，然后在编译的时候gcc崩溃了。试了php 5.5.5和php 5.5.14两个版本，都有这个问题，所以猜测是gcc的问题，可又因为Ubuntu 12.04自带的gcc只能这么老了，又不想从PPA装或自己编译个新版本，于是只好放弃自己编译php了。后来偶然敲了个sudo apt-get update && sudo apt-get upgrade，居然发现已经装了php5.4和php5-fpm！在nginx配置文件中新加一个server，再加一个location，写了个测试文件调用phpinfo()，发现可以用！

然后就可以装Wordpress了，看了一下“著名的”5分钟安装教程，把源代码包下载下来解压，放到指定目录，然后改wp-config.php，设置好数据库，用openssl生成一些随机字符串作盐。然后就可以在浏览器中打开安装了。这时发现所有css和js文件居然都打不开，看了一下nginx的error log，还以为是security.limit_extensions设置有问题，网上确实也有人有wordpress打不开，改这个设置的经历，不过我没看明白就在后面加了.css和.js，结果当然是没用的。后来看到[这篇问答](http://serverfault.com/questions/486368/nginx-and-php-fpm-403-forbidden)才解决，除了必须要加一个php后缀的location外，缺少的location也要加一个，index设成诸如index.php这种，不然在浏览器里输入URL如果不是php结尾的都不认。这样弄一下后，Wordpress至少可以正常显示了，为了照顾天朝用户，我还把wordpress源代码中使用Google前端库的地方全都换成了[360的地址](http://libs.useso.com/)。

后来zhangh又说换theme时需要FTP服务，这下我就囧了，几年没用wordpress它就变成这样了，怎么也不愿意装一个这种额外的服务，而且到时候用户权限又要折腾。网上搜了一下，除了装FTP服务，还有其他办法解决，可以看[这篇](http://94iw.com/wordpress-ftp-password)或[这篇](http://www.renhaibo.com/archives/154.html)，简单说来就是要么把wordpress源代码存放的目录用户和组都改成跟php-fpm进程相同，要么改一下wordpress源代码自动改权限。

真是不太爽的体验啊！我跟zhangh说，换是我要做这种展示类的页面很可能会放到github上去，就用Jekyll做静态站好了。不过zhangh说wordpress以后可以做商业定制，这个生态圈已经发展得很不错了。对于像他这样已经偏离技术比较远的人来说，确实很有道理，也就是我这样的人才会愿意自己花时间去折腾吧。
