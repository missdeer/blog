---
layout: post
author: missdeer
title: "试用C++ Builder社区版"
categories: Editor，IDE
description: 试用C++ Builder社区版
tags: C++
image: https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-02/vcldesign.png
---

偶然在Embarcadero的营销邮件中发现现在C++ Builder有Community Edition即社区版可以免费下载使用，想当年从大一买了自己第一台电脑开始，也曾用过6年左右C++ Builder写了些小程序，为了情怀也得试用一下。

之前那些年一直用的是C++ Builder 6.0，现在最新的版本已经到10.3了。可以到[Embarcadero的官网](https://www.embarcadero.com/products/cbuilder/starter/free-download)上注册一个账号，然后免费下载，官方会给注册邮箱发一封邮件，内含有效期一年的一个license，C++ Builder安装时需要用到这个注册码。下载到的是一个exe文件，是个在线安装程序，启动后可以选择安装哪些平台的开发工具，包括Windows，Mac，iOS，Android等等，然后会根据选择内容的多少，下载相应的安装包进行安装。

现在的C++ Builder支持两种方式进行Windows平台应用程序开发，一种以传统的VCL应用程序，另一种是新型的基于FireMonkey框架（即FMX）进行开发。其中VCL只支持Windows开发，而FMX则支持Mac，iOS，Android等多种平台应用程序的开发，但像Mac和iOS开发另外还需要一台Mac系统的机器做最后的签名、部署等步骤。

![VCL界面设计](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-02/vcldesign.png)

![FMX界面设计](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-02/fmxdesign.png)

最新的C++ Builder 10.3据称已经支持C++17标准。这之前我观察过，现在C++ Builder使用的编译器不再是完全自主开发的了，而是基于clang二次开发来的。C++ Builder的自动完成是通过cquery实现的，目前的效果一般般，又慢又要求多，比如源代码必须要已经保存到硬盘上，保存路径中不能含空格，必须是Windows 64bit为target等等，比Qt Creator都不如，更别提和宇宙第一IDE Visual Studio以及神器Visual Assist X比了。

![Code Insight](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-05-02/codeinsight.png)

现在从各方面来讲，除了情怀实在没其他理由再去用C++ Builder做实际产品开发了，VS和Qt的组合完胜。