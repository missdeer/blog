---
layout: post
title: "工作近况"
categories: job
description: 工作近况
tags: golang
---
公司里一个小项目的方案，原本就强烈建议小正太把业务逻辑提出来，单独写个server，不要把应用层代码写到nginx push stream module里去，让人家module只做单纯的协议层数据转发。小正太一直以性能消耗要多一次请求为由想把业务逻辑合到nginx的module里去，我真是无语透了，这是多丑多dirty的设计和实现啊！好在昨天又讨论这个方案时，另一个同事基本上同意我的说法，然后两个人把小正太说得哑口无言。现在公司里的人，上到boss、CTO、Director，下到team leader、PM、普通developer，几乎都对软件工程、架构设计毫无概念，脑子里眼里只有source code。很久以前我就在想，如果有人说公司能做出现在这种产品真不容易，我肯定竭力赞同，在条件这么恶劣的情况下一群水平这么次的员工还是能开发出来每年卖上千万刀的产品，确实很不容易啊！



