---
layout: post
title: 新项目计划——密码管理
categories: Shareware
description: 有了几个idea做新项目
tags: shareware Qt Golang Financing
published: true
---

这两天看论坛，又想到两个对我来说比较有用的东西。其中一个是密码管理。

现在的互联网似乎是越来越不安全了，或者说对安全的要求越来越高了，而几乎每个人也同时会拥有一堆的用户名和密码，而如何管理这些用户名和密码则是一件非常重要的事情。以我个人经历为例，我最开始上网的时候，国内的互联网服务还是比较单调的，而且数量也不多，我差不多把所有地方的用户名和密码全都设成一样的。后来随着注册的服务越来越多，情况也有些变化，比如有的服务只要求用户名，而有的服务则要求用email地址作为登录名，再后来就是因为网民数量暴增，有些服务我惯用的用户名已经被其他人注册了。密码也有类似的情况，最早我是使用一个全数字的弱密码，那时候完全没有安全意识，所有的服务都用同一个密码。后来有的服务不允许使用全数字的密码，我第一次碰到这种情况貌似是2005年魔兽世界公测时遇到的，然后我就随意地在最后添加一个字母，再后来参加工作，公司对信息安全相当关注，要求系统登录密码由大小写字母数字及特殊字符混合组成且3个月换一次，不能使用前5次用过的密码。再之后则是遇到CSDN被泄漏600万用户名和密码，然后忙不迭得把所有还记得的常用服务使用了相同密码的全都改掉。随着使用的使用的不同的用户名和密码的情况越来越多，我就把这些信息都记到一个笔记软件中。有一次小偷进了屋里，把几个平板都偷走了，而那平板上笔记软件都是默认登录的，于是又只好全部改一遍密码。不过直到现在我仍然只是使用笔记软件记着诸多常用服务的用户名和密码，而没用那些密码管理软件。目前最流行的密码管理软件大概就是三个，[1Password](https://agilebits.com/onepassword)，[LastPass](https://lastpass.com/)和[KeePass](http://keepass.info/)。前两个是付费的，后一个是开源免费的。我不用这些软件的原因有几个：

- 我不想付这笔钱给别人；
- 我不是很信得过把这些信息保存到别人的服务器上；
- 付费软件不开源，我也不太信得过；
- 那个开源免费的软件原生不是跨平台的，跨平台都是第三方实现的，而且没有特别方便的互通或同步方法。

我几乎每天都可能在Win7/Win8/Mac/Linux/iOS/Android上来回切换，所以跨平台是我的刚需，跨设备同步更是我的刚需。所以我打算自己实现一个密码管理程序，这个程序的功能其实很少：

- 密码生成；
- 将信息用可逆的高强度加密算法加密；
- 把加密后信息保存到服务器上；
- 能将服务器上的加密信息取回解密并与本地的信息合并。

我打算把这个小程序放在github上，我希望能以此来吸引一些人来帮忙提高它的安全性。