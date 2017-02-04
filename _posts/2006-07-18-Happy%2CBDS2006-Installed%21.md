---
layout: post
title: Happy,BDS2006 Installed!
categories: 
 - imported from CSDN
description: Happy,BDS2006 Installed!
tags: 
---

历尽千辛万苦，在eMule 上下了一个多星期，当然不是每天24小时开着，总算把前面3个CD 的镜像拖下来了，开始还以为不能用，因为看了网上n多的帖子文章，说前2个CD 的要repack 的才行，果然在Alcohol120% 里加载那几个cue 文件时，都说不能访问文件，用UE打开一看，里面的文件名似乎有点问题，改成对应的bin 文件的名字，再来加载，就可以了，如果只是要装一下C++Builder 和Delphi 的for Win32部分，很快的，不用第4个CD 的，我都没down 完，反正可以装了，装完之后，C++Builder 部分显示的是Preview 的，但是可以正常启动使用，也可以编译程序用，简单拖了个窗体，放个Button 和TMainMenu，都可以用。然后去Borland 的网站上down个Update2 的包下来，我的是Arch 版的，Update2 包也要对应的Arch 版的，装上后，从原来不要求注册的，变成要注册了的。在google 搜索的话，可以找到很多patch 的下载，其实有个更简单的方法，用UE 打开`BDS\4.0\bin`目录下的sanctuarylib.dll 文件，十六进制显示，搜索`8D742444B90400000033D2F3A75F7504`，把最后的`04`改为`00`，保存一下，再启动BDS，就可以发现不用注册了，而且C++Builder 也不再是Preview 了，哈哈，happy！
