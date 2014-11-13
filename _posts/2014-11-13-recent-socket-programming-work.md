---
layout: post
title: "最近的网络开发工作"
categories: Coding
description: 最近的socket开发工作
tags: Coding socket asio
---
之前说过，我把一个项目中的程序线程数都尽量减少了，差不多就是一个程序用一个线程来跑一个event loop来服务所有socket，结果这几天发现似乎性能有点跟不上了。

用于消息中转的程序使用boost.asio来实现了一个tcp server，当有50个client来连时，就很有可能处理不过来，当然这个数目跟机器配置有关系，我的E7200双核CPU外加2GB内存的开发机上，另外跑了一些杂七杂八的程序，就是这种情况，QA那里E7400的CPU，这个数字可以达到200才表现出来跟我的机器上差不多。

然后我增加到3个线程各跑一个event loop，在开发机上50个client测试了几遍没出现过问题，等增加到85个client，就又不行了。接着我又增加到5个线程，85个client也能抗住了。等我增加到100个client，发现加再多线程也没用了，原来CPU已经0% idle了。

不过这个简单的实验至少可以证明，增加线程数和event loop数可以有效增加server的处理能力，当然机器性能要能跟上。

