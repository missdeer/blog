---
layout: post
image: https://blogimg.minidump.info/2018-07-10-clang-on-windows-for-qt.md
author: missdeer
title: "Clang on Windows for Qt"
categories: CPPOOPGPXP
description: Clang on Windows for Qt
tags: Clang Qt
---

几年前也曾经试图折腾过Clang on Windows，那时候的完成度还不高，只能配合MinGW使用，而且头文件搜索路径还是源代码中硬编码的。

现在完成度已经很高了，Chrome for Windows已经转而使用Clang编译。Clang官方支持2个target，分别配合MinGW和MSVC使用，只要在设置好PATH和target，clang就能自动使用对应的头文件，库文件，链接器等等。

偶然发现Qt 5.11.0已经带了win32-clang-msvc这个mkspec，而5.11.1增加了win32-clang-g++，这意味着在Windows上已经可以使用clang编译Qt程序，并且随意切换target。

Qt官方提供msvc2015和msvc2017编译后的二进制文件下载，可以直接使用从[LLVM官网](http://llvm.org/)下载的[Windows installer](http://llvm.org/builds/)，甚至已经在LLVM 7.0的[snapshot](http://prereleases.llvm.org/win-snapshots/)可以使用。可以编写一个批处理文件来设置环境变量：

```batch
set VS140COMNTOOLS="C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\"
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_amd64
set PATH=%PATH%;"C:\Tools\LLVM-7.0.0-r336178-win64\bin\";C:\Qt\Tools\QtCreator\bin\;C:\Qt\5.11.1\msvc2015_64\bin\
```

之后每次只要先执行这个批处理文件，然后执行命令：

```
qmake -r -spec win32-clang-msvc src.pro
nmake 或 jom
```

就可以使用clang编译Qt程序了，最终链接的是msvc版本的Qt库。

至于使用MinGW的target，我现在使用msys2的版本。msys2提供编译好的MinGW-w64套件，有提供32位和64位两个版本。Qt也有现成的编译好的文件，分别有32位和64位，静态链接和动态链接共4个版本，有时候静态链接的版本会迟一点发布。使用pacman安装：

```bash
pacman -S mingw-w64-i686-qt5 mingw-w64-i686-qt5-static mingw-w64-i686-clang
pacman -S mingw-w64-x86_64-qt5 mingw-w64-x86_64-qt5-static mingw-w64-x86_64-clang
```

这会下载几GB的东西，安装后可能会占用几十GB的空间。之后如此使用：

```bash
PATH=/mingw64/bin:$PATH /mingw64/bin/qmake -r -spec win32-clang-g++ src.pro
PATH=/mingw64/bin:$PATH /mingw64/bin/mingw32-make
```

至于Qt程序本身，并不会怎么受clang影响，除了可能会要求更规范一点？多数问题然后是MSVC和MinGW套件的区别的问题，在`.pro`文件中，则使用`win32-*g++*`和`win32-*msvc*`来区分两种套件即可。