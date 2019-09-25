---
layout: post
image: https://blogimg.minidump.info/2015-04-23-always-crash-bug-with-dump-file.md
author: missdeer
title: "老是分给我dump文件分析crash bug"
categories: Job
description: 老是分给我dump文件分析crash bug
tags: dump crash WinDBG
---
进这公司两周多了，分给我5个crash bug让我看。第一个因为没有symbol文件了，所以没继续看。第二个在Mac上，幸亏可以100%方便地重现，然后找到一点线索，转给其他team去了。后面三个都是只有dump文件让我看，一个是只能看到项目代码里从容器里取出一个野指针，一个是只能看到项目代码里似乎一切正常但进了CRT后一个字符串拷贝操作崩溃了，最后一个是在基类里有一个方法会调用一句

```cpp
delete this;
```

该类的析构函数倒确实是`protected`的，但从dump里看似乎这个对象的完全正常，从内存布局上看从`virtual table ptr`开始，到里面各个成员变量都是死前该有的样子。我现在想得到的解释是这个对象被连续释放了2次？

我翻出好久没看的[《Windows高级调试》](http://book.douban.com/subject/3781532/)和[《软件调试》](http://book.douban.com/subject/3088353/)，又一次沮丧地发现目前似乎没有专门针对postmortem debugging的比较系统的方法讲述或讨论，绝大多数是在线调试的。叹气！昨天又从当当上订了一本[《格蠹汇编——软件调试案例集锦》](http://book.douban.com/subject/22994051/)，希望能从中有所启发。叹气！我还觉得或许熟悉MSVC生成代码的方式会对这个有所帮助，也许应该再去学点逆向工程。叹气！

每天stand up meeting是我现在最害怕的事情，我实在说不出自己做了什么。
