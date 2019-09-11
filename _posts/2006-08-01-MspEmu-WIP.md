---
layout: post
author: missdeer
title: MspEmu W.I.P.
categories: 
 - imported from CSDN
description: MspEmu W.I.P.
tags: 
---

在脚本里写了个很简单的函数，然后在宿主程序里调用它，死活调用不成功，看一下错误信息，说是试图调用一个nil 值，可是我明明在脚本里定义了这个函数的呀。其它部分倒还好说，在宿主程序中可以取得全局的脚本中的变量值，脚本也可以比较顺利地调用宿主程序定义了并注册给解释器的函数，现在就是这个搞不定，郁闷，只好操上蹩脚的english，上mail list 里问一下了。如果不行，还有一条路可以走，想办法能不通过函数调用就取得宿主程序中的变量值。开源的，文档就是少啊！
