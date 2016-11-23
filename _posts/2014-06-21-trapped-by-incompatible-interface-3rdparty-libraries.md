---
layout: post
title: "被第三方库接口变化给坑了"
categories: Coding
description: 被第三方库接口变化给坑了
tags: Coding
---
[Yiili](http://yii.li)论坛程序是从[wetalk](https://github.com/beego/wetalk)改过来的，所以是用了[beego](https://github.com/astaxie/beego)这个Web Framework的。前两天Beego从1.2.0升级到1.3.0，有一个用到的接口被删了，用另一个新增的接口替代，于是Yiili就编译不过了。其实据说这个被删掉的接口已经有3，4个版本标记为deprecated了，只是我才接触beego差不多1个月，所以肯定不会知道这回事的，于是即使自己照猫画虎地尝试修改，即使能编译通过了，运行也仍然不正常。[Beego的官方论坛](http://bbs.go-china.org)上也有人在喊这个问题，一直到第二天，Beego的作者astaxie大概实在受不了人的呱噪，直接把wetalk的[不兼容代码给改了](https://github.com/beego/wetalk/commit/5f90e2a1a4c49d9d95b2361e954d959e7e68a310)。这次事件给我的感觉非常不好，还跑到Go的中文邮件列表去问遇到这种第三方库接口变化引起不兼容的问题该怎么解决。结果有人说，官方的做法是把第三方库在自己的代码库里copy一份，唔，这是我最不喜欢的做法，像svn external，git submodule不都是为了避免这种做法吗！但是go get不支持版本，所以是没办法做到的。还有人提出个我觉得还能接受的办法，在GOPATH里加3个路径，第一个专门放go get取下来的第三方库，里面的东西随时可以删掉，第二个专门放被自己修改过或认为是stable的第三方库，可以保证自己的项目能编译通过的，第三个专门放自己的项目代码。


