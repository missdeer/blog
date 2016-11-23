---
layout: post
title: "工作近况"
categories: Job
description: 工作近况
tags: Go
---
公司里一个小项目的方案，原本就强烈建议小正太把业务逻辑提出来，单独写个server，不要把应用层代码写到nginx push stream module里去，让人家module只做单纯的协议层数据转发。小正太一直以性能消耗要多一次请求为由想把业务逻辑合到nginx的module里去，我真是无语透了，这是多丑多dirty的设计和实现啊！好在昨天又讨论这个方案时，另一个同事基本上同意我的说法，然后两个人把小正太说得哑口无言。现在公司里的人，上到boss、CTO、Director，下到team leader、PM、普通developer，几乎都对软件工程、架构设计毫无概念，脑子里眼里只有source code。很久以前我就在想，如果有人说公司能做出现在这种产品真不容易，我肯定竭力赞同，在条件这么恶劣的情况下一群水平这么次的员工还是能开发出来每年卖上千万刀的产品，确实很不容易啊！

最近老想着给[Yiili](http://yii.li)加上memcached或redis。以前没涉及过web对这类东西全无了解，现在也只是知道了点概念。从概念和目标上说来，memcached是缓存，redis是内存数据库。而因为可能是大多数时候它们都把热点数据存在内存中，很多情况它们的作用就当成cache用了。memcached的优势在于集群，redis的优势在于单点性能好，虽然现在还在beta的新版redis也在集群方面做了很多工作，但具体情况怎样还有待实践证明。以Yiili目前的情况即使不用这些东西也能跑得好好的，但我就是开始对这些感兴趣了。初步看来Yiili用一个redis就足够了，我暂时也没找到多少数据是要cache的，顶多就是几个帖子列表和热门帖子的内容。然后就是找go的第三方库提供memcached或redis的客户端功能，找到一个叫[gomemcache](https://github.com/bradfitz/gomemcache)的，貌似作者就是memcached的作者，还发现那厮去年又出了个memcached的演进产物[groupcache](https://github.com/Go/groupcache)，大概意思是有些场合用groupcache比memcached更合适，囧rz。至于redis的go版客户端实现就比较多了，[这篇文章](http://www.cnblogs.com/getong/archive/2013/04/01/2993139.html)里还有人对几个实现做了一些比较，究竟哪个更好一点也没有明确的结论，大致上说[redigo](https://github.com/garyburd/redigo)和[redis](https://github.com/gosexy/redis)好的人更多点的样子，前者是个纯粹的Go实现，后者貌似只是对Redis官方C客户端的包装，似乎要用cgo才能用，但拥有更好的却也不明显的性能，我也许会选前者吧。

