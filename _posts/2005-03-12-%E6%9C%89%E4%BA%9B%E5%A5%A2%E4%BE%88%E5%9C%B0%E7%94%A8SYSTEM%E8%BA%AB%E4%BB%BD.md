---
layout: post
image: https://img.peapix.com/10433023165117392861_320.jpg
author: missdeer
title: 有些奢侈地用SYSTEM身份
categories: 
 - imported from CSDN
description: 有些奢侈地用SYSTEM身份
tags: 
---

照着bingle的代码，改了一下自己用，用来搭配LLYF ProcessHelper，现在ph.exe 可以以SYSTEM 身份运行了，至少在Administrator 组用户下可以以SYSTEM 身份运行了，其实也就是能多看到其它两三个进程的命令行和模块列表，至于kavsvc.exe和kav.exe 还是不行的，也真是厉害，能保得这么严，当然IceSword 的进程也打不开。

现在已经渐渐地习惯于XP 的华丽界面了，只要不用VC，写程序都跑到XP 下去，于是开始的时候，用sc.exe 来start 一个服务，用得好好的，后来跑到2000 下，发现2000 没有sc.exe 这个程序，总之不想再另外加个依赖程序，于是只好自己用代码来StartService，可是为了传递参数费了点劲，原来在命令行如果一个参数内有空格，就要加双引号，现在在一个字符串里，是不用引号了，害得我又上网瞎整了一个小时。

其它的，用到了net stop，还有rundll32.exe，这些应该是2000/XP/2003 系统都有的了，不过我想还是得找机会自己写代码来运作更可靠一点。于是，暂停服务，删除服务也不过是调用几个API，以前（还不知道有sc.exe的时候）写过一个对服务进行操作的程序，正好都搬来用用。rundll32 也不过是调用DLL里的函数，自己LoadLibrary 再GetProcAddress 来调用一下就成了。

另外，偶然地发现了其它的Bug，以SYSTEM 身份运行以后，在保存文件对话框中，不能直接到达桌面之类的特殊文件夹了，说什么引用位置错误，大概这个和进程的运行身份有关吧，暂时还想不到解决办法。还有，自从加了获取进程命令行之后，在保存进程列表的时候，总是会异常。原来是因为有些进程根本不能获得命令行，所以在ListView的最后那栏还是没填东西进去，但在保存时，还是会试图读些东西出来，就会Out of range了。
