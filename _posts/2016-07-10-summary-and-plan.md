---
layout: post
title: "近期小结和计划"
categories: life
description: 近期小结和计划
tags: mobile Shareware
---
从淘宝花了几十块钱买了个Nexus 5的尾插排线，然后自己掰开后盖换上，Nexus 5复活了！有点小遗憾是我的手工不好，换上后不是很紧凑的样子。

日志分析程序可算是全部完成了，最后支持了纯文本关键字，正则表达式，SQL WHERE clause和Lua脚本共4种扩展，可以将一些常用的搜索语义以扩展的形式保存下来，并从菜单项中激活，不用每次在combo box中输入，而且combo box中输入只支持纯文本关键字和正则表达式2种而已。略微值得一提的是，Lua脚本扩展只是通过替换sqlite的match()函数实现的，性能比想象中的要好得多，看来Lua在嵌入方面确实是很有优势的。另外，LuaJIT可以提供更好的运行时性能，但只兼容Lua 5.1，而官方Lua版本已经是5.3.3了，这个版本跨度太大，已经不再二进制兼容了，也就是说，在Windows上直接替换同名的Lua DLL是不能运行的，在Mac是更是强制验证了版本号。最后我想了想，觉得这种扩展对高版本的Lua语言特性并没有什么需求，于是直接链接了LuaJIT。

之前跟人合作的滚球推荐app就这样弃坑了，做了大半年，说放弃就放弃了，我想主要原因还是因为没收他们钱，他们什么成本都没有，所以随时可以弃坑，反正也没损失，开发阶段也是随心所欲想提需求就提需求，想改需求就改需求，就当是“试验田”。一次教训吧。果然“只缺程序员”系列是不靠谱的，即使是合伙，也得收钱才开工。

下半年计划3个项目：

* 密码管理app上架
* 双色球app更新
* 围棋云评论服务上线