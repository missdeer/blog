---
layout: post
title: "netlink需要root权限"
categories: job
description: netlink需要root权限
tags: netlink root linux
---
这周一直在按计划重构Relay，今天就做到改用netlink监控进程退出事件。发现如果是普通用户的话在bind socket时就会返回权限不够的错误码，尝试用sudo来运行就可以正常bind了，这让我不由郁闷了好一阵子，因为我一直想的是Relay可以用普通用户就可以正常运行的。后来再想想，把Relay当成像nginx之类的服务来设计的话，要求用户以root权限来启动似乎也不是太过分哈。照计划中，估计也只有Linux上用netlink是要用root吧，Windows和BSD系的方法我猜是不需要特别的权限吧。

怎么想心里还是有点不爽啊。
