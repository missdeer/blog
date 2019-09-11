---
layout: post
author: missdeer
title: MspEmu W.I.P.
categories: 
 - imported from CSDN
description: MspEmu W.I.P.
tags: 
---

意外地发现，只要对hhctrl.ocx 执行implib 导出的lib 文件就可以直接用在BDS2006 的工程里了，再也不用LoadLibrary 和GetProcAddress 了，再也不用为什么时候FreeLibrary 而发愁了，一切都变得那么美好，意外地发现，sf.net 上还有个叫bccSDK 的项目，专门把MS 新发布的一切库移植到可以用Borland 的C 编译器下使用，其实就是一堆的lib 文件，当然还有那个htmlhelp.lib，不过我没有用，因为我已经自己暂时解决了，只是奇怪的是，以前明明我也这样做过，为什么不行呢？

另外，添加了插件浏览窗口，其实就是把LLYFSpy 中的那段代码copy 了过来，有点难的是，我把插件按后缀名分成了三类，但在添加源代码浏览功能时遇到了困难，还是因为我对HTML接口的不熟悉，找不到方便的途径能快捷地获取当前选择的插件的文件名，只好暂时把这个功能屏蔽了。

下雨了，后面几天就把脚本和宿主程序之间的交互功能完成了吧。
