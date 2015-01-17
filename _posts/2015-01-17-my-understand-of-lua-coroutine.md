---
layout: post
title: "我对Lua coroutine的理解"
categories: coding
description: 我对Lua coroutine的理解
tags: Lua coroutine thread fiber goroutine
---
今天一个人闲来无事跑去图书馆续证，结果发现证上说的2年有效期虚惊一场，不知何时起已经改成永久有效了。于是又去中文外借室逛了一圈，还真找到几本感兴趣的书。其中一本是老毛子写的《深入实践Boost》，里面有一段讲到了Boost.coroutine，看了一遍不是很明白其中的用意，于是我又想起Lua中的coroutine来了。Lua在几年前学过用过，写过几万行的代码，但最精髓的部分（coroutine，table高级用法等）却被我略过了。于是这次在网上逛搜了一通相关的中文文章，终于有了一点点理解。

之前虽然也知道Lua coroutine可以resume和yield，但具体怎么用却完全没有头绪。这次我想明白了一点，应该是我之前被脑海中根深蒂固的Windows thread和pthread之类的对照物给影响了。一般Lua的教程，包括Lua的发明人，在讲到Lua没有传统意义上的thread，只有coroutine来实现相关的需求，而且Lua本身喜欢把Lua coroutine说成thread，这点很容易误导人。我就是从那时起想着传统的thread是如何并行的，Lua coroutine要如何做到并行，然后一直摸不着头脑，直到今天。相对来说，Go语言中的goroutine确实是跟传统的thread用途用法都非常相近。

其实在我现在的理解中，Lua coroutine只是一种编程风格的转变，跟thread、并行啥的没多大关系。举个例子，一个简单的使用Lua coroutine的片段：

```lua
task = function(i)
    print("prepare task environment for", i)
    print("task final result", coroutine.yield(i+10) + 20)
end

co1 = coroutine.create(task)
co2 = coroutine.create(task)
local s, t1 = coroutine.resume(co1, 1)
local s, t2 = coroutine.resume(co2, 2)
-- 高潮来了，到这时2个task coroutine都自己主动yield出来，并传了个值出来，我们这里保存到t1，t2
-- 我们要拿t1和t2分别去做点事情，比如做个耗时的计算，然后再把计算结果再传回coroutine里去
-- 这里为了简便起见，这个耗时计算就是自己加自己一遍，假设这时t2的计算先完成，于是我们先resume了co2
print(s, t1)
print(s, t2)
coroutine.resume(co2, t2 + t2)
coroutine.resume(co1, t1 + t1)
```

这段代码运行结果如下：

```
prepare task environment for	1
prepare task environment for	2
true	11
true	12
task final result	44
task final result	42
```

前两行是准备任务环境，中间两行是准备工作完成，最后两行是任务最终完成。

问题是，这么简单的问题，为什么一定要引入coroutine来解决呢?这就是我前面说的，这是编程风格的转变。其实我们传统的写法应该是这样的：

```lua
prepare_env = function(i)
    print("prepare task environment for", i)
    return i+10
end

final_task = function(i)
    print("task final result", i + 20)
end

t1 = prepare_env(1)
t2 = prepare_env(2)
print(t1)
print(t2)

final_task(t2 + t2)
final_task(t1 + t1)
	
```

这段代码的运行结果跟前面的代码一模一样。代码的区别就在于没有使用coroutine，而且把原来作为coroutine的函数`task`拆成了两个函数`prepare_env`和`final_task`。用coroutine的好处在于一个函数涵盖了整个任务的逻辑，思维连贯。不用coroutine的做法就需要在每次yield的地方分界，拆成几个零碎的小函数。两种不同的编程风格，不在于谁好谁坏，只有看个人的喜好，以及当时的场景，选择哪种更合适。

联想到现在非常火爆的Node.js，其实使用Lua coroutine的这种编程风格非常适合做Reactor模式的socket并发编程。每个socket连接一个task coroutine，用于处理数据，处理完后yield回主函数，让主函数做select/epoll，拣取出有变化的socket，找到对应的coroutine就resume进去处理数据，如此循环，就能做到Node.js这种重IO轻计算的任务。现在有个叫[Luvit](https://luvit.io/)的项目，是用Lua实现像Node.js的框架，但它貌似模仿得过头了，也是用回调函数的风格，这就失去了Lua用coroutine的原汁原味，既讨不得Lua社区的好，又吸引不了其他已经被Node.js吸引走的人。

这就是我对Lua coroutine的初步理解。
