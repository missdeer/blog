---
layout: post
image: https://img.peapix.com/14028497192382555247_320.jpg
author: missdeer
title: LLYF VirtualTyper W.I.P.
categories: 
 - imported from CSDN
description: LLYF VirtualTyper W.I.P.
tags: 
---

整了下Scintilla，把它弄进去了，初步了解了怎么让它支持某种语言的关键字高亮，还是非常非常方便简单的！以后还要加入代码折叠，行号显示以及自动完成功能。如果是要专心地完成一个编辑器，要做的事情还是比较多的，看一下SciTE 和Notepad++ 就知道，不过我可能不需要做那么完整，只要有个看起来比RichEdit 强一点的编辑框就够啦，哈哈！这部分代码以后重用的机会肯定还是有的，比如MspEmu 中。另外就是，对关键字高亮的支持，应该写一个通用的接口，然后把语言相关的信息全都写到外部的配置文件中，这样才是比较经济又灵活的方案，呵呵，然后要动态判断是属于哪个语言的代码，再动态地修改Lexer 属性。这样以后可以在不修改主程序的情况下，动态地添加对新的语言的支持。

刚刚看到L.L.的MSN 上nickname 变成什么“牛魔王的女儿……”云云，我就说“异曲同工啊”，然后突然想起有一次小玉玉毫无任何征兆地发了封邮件说“樊樊长得很鬼斧神工耶”……
