---
layout: post
image: https://img.peapix.com/1358620477538904701_320.jpg
author: missdeer
title: LLYF VirtualTyper W.I.P
categories: 
 - imported from CSDN
description: LLYF VirtualTyper W.I.P
tags: 
---

就先定这么俗的一个名字吧！

这两天一直在想这个东西，想它应该有哪些功能，应该有什么样的架构。

首先定的目标是，一定要有非常好的可扩展性，其次是对QuickMacro 脚本的兼容性。

最近对使程序具有良好的可扩展性比较有兴趣。看到Eclipse，Emacs 这些东西，就觉得可扩展性是多么有趣的一件事件。但是一方面，为了能对 QuickMacro 有比较高的兼容性，可能不得不对它的插件机制也有一定的兼容，但是现在看来，总觉得它的插件机制不是我喜欢的那种，我比较喜欢Eclipse 的那种，用配置文件描述插件，而实际功能在需要时才装载，当然我肯定不会做得完全像Eclipse 一样，没能力，也没必要，呵呵。也许我会把QuickMacro 的那套都照搬过来，再加上仿Eclipse 的那套。也许，我会以我自己的方式来兼容QuickMacro 的那套，因为目前看来它还没有多少插件是有价值一定要兼容的。倒是它的脚本语法是一定要兼容，这样才能让我的程序具有“吸星大法”，发扬“拿来主义”，只要用户愿意，就可以无需任何额外的操作，直接使用它的脚本。

因为可以采用仿Eclipse 的插件方式，所以主程序要做的只是提供最基本的最重要的框架，需要的是极大的灵活性，一方面可以对程序界面进行一定程度的自定义，另一方面，大量的功能特性都可以委托插件来完成，比较脚本解释器，这样一来，只要定义一个良好的比较通用的解释器接口，就可以任意挂接任何脚本语言的解释器，不光是所谓的“按键语”，还可以随意添加其它的语言支持，比如Lua、Tcl、Python！主程序可以只提供最简单的功能，比如硬件模拟，系统底层调用，像定时器、线程管理这些，统一的接口可以保证程序的稳定性。另外的像窗口寻找之类的，都可以通过插件来实现。

接下来要考虑的是，哪些部分是要由主程序实现，哪些部分交给插件实现，插件和插件之间的交互应该以什么样的形式进行。还有个比较次要却最先让人感受到的是，程序界面应该怎么实现。一般说来，这样的程序也就只有两大部分：脚本管理和脚本编辑。有点犹豫的是，要提供占用比较多资源的豪华界面，还是轻巧型的朴素界面呢？

现在想的到就是这些，其余的慢慢再想，嘿嘿……
