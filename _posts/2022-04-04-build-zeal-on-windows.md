---
image: https://fastly.jsdelivr.net/gh/missdeer/blog@master/media/2022-04-04/zeal.png
layout: post
author: missdeer
featured: false
title: "Windows上编译Zeal"
categories: cmake
description: "Windows上编译Zeal"
tags: cmake Qt
---
鉴于最近买了个梯子，不大稳定，速度也没以前的快，直接打开在线的开发文档就感觉不大舒服了，想在本地弄个快的。今天编译试用了一下[Zeal](https://github.com/zealdocs/zeal)，感觉不错，比当时刚出来的时候好多了，不会随便动两下就遇到奇怪的bug，界面也不那么丑了。

官网上的安装包是3年半前的了，要最新的需要自己编译，看一下文档说明，还算简单。

首先需要准备好MSVC和Qt5。

然后下载依赖项[libarchive](https://www.libarchive.org/)和[sqlite3](https://sqlite.org/download.html)。都下载官方预编译的包就行了，sqlite3稍微麻烦一点，只能下载到`.h`，`.dll`和`.def`文件，没有`.lib`文件，需要自己用命令从`.def`生成`sqlite3.lib`：

```cmd
lib /DEF:sqlite3.def /OUT:sqlite3.lib /MACHINE:x64
```

最后安装工具cmake，就可以开始编译了。

打开cmd命令行窗口，假设libarchive和sqlite3分别存放在`C:\Project\libarchive`和`C:\Project\sqlite-dll-win64-x64`，进入zeal代码所在目录，敲命令：

```cmd
cd zeal
set Qt5_DIR=C:\Qt\5.15.2\msvc2019_64
cmake.exe -B build -DLibArchive_LIBRARY=C:\Project\libarchive\lib\archive.lib -DLibArchive_INCLUDE_DIR=C:\Project\libarchive\include -DSQLite_LIBRARY=C:\Project\sqlite-dll-win64-x64\sqlite3.lib -DSQLite_INCLUDE_DIR=C:\Project\sqlite-dll-win64-x64 -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_C_FLAGS="/utf-8" -DCMAKE_CXX_FLAGS="/utf-8"
cmake.exe --build build --config Release
```

这样应该就能编译出来`zeal.exe`了。

如果有`Ninja`，则可以指定cmake使用ninja以便并行编译项目，加快编译速度：

```cmd
cd zeal
set Qt5_DIR=C:\Qt\5.15.2\msvc2019_64
cmake.exe -B build -DLibArchive_LIBRARY=C:\Project\libarchive\lib\archive.lib -DLibArchive_INCLUDE_DIR=C:\Project\libarchive\include -DSQLite_LIBRARY=C:\Project\sqlite-dll-win64-x64\sqlite3.lib -DSQLite_INCLUDE_DIR=C:\Project\sqlite-dll-win64-x64 -DCMAKE_MAKE_PROGRAM=C:\Tools\ninja.exe -DCMAKE_BUILD_TYPE=Release -G"Ninja" -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_C_FLAGS="/utf-8" -DCMAKE_CXX_FLAGS="/utf-8"
cmake.exe --build build
```

可以看到两种方法的区别，前一种方法cmake生成了MSVC的工程文件，cmake编译时调用MSVC的构建工具，所以可以在编译命令中加`--config Release`指定编译variant，后一种方法生成的是Ninja工程文件，直接指定了编译variant，后面的编译命令不需要再指定编译variant，然后cmake调用了ninja进行编译，ninja会自己根据当前CPU的核数自动启动多个并行编译任务。

编译出`zeal.exe`后，要把`archive.dll`、`sqlite3.dll`拷贝到相同目录，再用Qt的`windeployqt.exe`把依赖的Qt库都拷过来，最后把Qt的Tools目录下的OpenSSL两个文件`libcrypto-1_1-x64.dll`和`libssl-1_1-x64.dll`拷贝过来，就能双击运行`zeal.exe`了，跑起来的界面大概是这个样子：

![zeal](https://fastly.jsdelivr.net/gh/missdeer/blog@master/media/2022-04-04/zeal.png)