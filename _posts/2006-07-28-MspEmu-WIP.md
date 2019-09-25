---
layout: post
image: https://blogimg.minidump.info/2006-07-28-MspEmu-WIP.md
author: missdeer
title: MspEmu W.I.P.
categories: 
 - imported from CSDN
description: MspEmu W.I.P.
tags: 
---

突然觉得我这些天一直在做着一件毫无意义的事情。也不管那么多了，现在只能咬着牙，硬着头皮把它整完了，这季度考评中有5分还全指望这个了。

先写个Todo list吧：

1、能提供一个输出界面，一个接口给脚本，让脚本有能力向宿主程序输出一些内容，就像控制台那样的形式；

2、数据显示用的ListView 要改成Virtual ListView，主要是看到有一种情况下可能会有大量数据需要显示，同时也对相关数据传递的方案进行仔细考察，不然效率影响太明显；

3、是否需要顺便集成一个简单的脚本编辑器，说是简单，至少也得对这嵌入的三种脚本语言提供关键字高亮的支持，这个还是待定，如果进度不紧张再添加；

4、对Lua/Python/Tcl 嵌入支持，这个说了很久了，唯一一点一定要做到的，不然整个东西真的是一点点的用处都没用了，因为没有通用性，拿不出去；

5、在界面上把协议模拟的痕迹先抹掉，以后再说了，纯粹使用GDI 画所有的东西出来还是烦了点。

暂时先只有这些吧。

Firefox 2 Beta 1太不稳定了，崩溃了几次了，还是换用1.5了。以后要习惯用Emacs、MinGW 还有Eclipse！！
