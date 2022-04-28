---
image: https://blogassets.ismisv.com/media/2022-01-10/cmake.jpg
layout: post
author: missdeer
featured: false
title: "Windows上cmake适配多种构建工具和编译器"
categories: cmake
description: "Windows上cmake适配多种构建工具和编译器"
tags: cmake
---
用CMake的好处一是屏蔽了多种常见编译器的编译选项和命令行参数差异，二是可以选择目标构建工具。我前段时间要写一个SDK，希望SDK能在主流操作系统（Windows，Linux，macOS）上跑，能用常见的编译器套件（MSVC，GCC，Clang，Intel C编译器等等）编译，这正好是CMake的用武之地。

## 使用不同的构建工具

### NMake

以Windows为例，我想用MSVC编译，则用如下命令行：

```txt
mkdir build
cd build
cmake.exe -DCMAKE_BUILD_TYPE=Release -G"NMake Makefiles" -DCMAKE_PREFIX_PATH=U:\boost_1_77_0  ..
nmake
```

### JOM

如果嫌`nmake`编译速度慢，Qt提供了一个跟`nmake`相近但允许像`GNU make`一样加`-j`参数并行编译的工具[JOM](https://download.qt.io/official_releases/jom/)，命令行如下：

```txt
mkdir build
cd build
cmake.exe -DCMAKE_BUILD_TYPE=Release -G"NMake Makefiles JOM" -DCMAKE_PREFIX_PATH=U:\boost_1_77_0 -DCMAKE_MAKE_PROGRAM=C:\Qt\Tools\QtCreator\bin\jom\jom.exe  ..
C:\Qt\Tools\QtCreator\bin\jom\jom.exe -j 12
```

### Ninja

也可以用现在很流行的另一个构建工具[Ninja](https://github.com/ninja-build/ninja)，它默认自动进行并行编译，命令行如下：

```txt
mkdir build
cd build
cmake.exe -DCMAKE_BUILD_TYPE=Release -G"Ninja" -DCMAKE_PREFIX_PATH=U:\boost_1_77_0 -DCMAKE_MAKE_PROGRAM=C:\Tools\ninja.exe  ..
C:\Tools\ninja.exe
```

## 使用不同的编译器

### Clang for Windows

前面是用了MSVC，如果想用Clang，Clang在Windows上有2种，一种是使用MSVC的套件，前端命令工具是`clang-cl`，另一种是使用MinGW，前端命令工具是`clang`，在cmake中只要参数设置一下就可以了：

```txt
mkdir build
cd build
cmake.exe -DCMAKE_BUILD_TYPE=Release -G"NMake Makefiles" -DCMAKE_PREFIX_PATH=U:\boost_1_77_0  -DCMAKE_CXX_COMPILER=clang-cl  ..
nmake
```

### Intel oneAPI Compiler

以前Intel C编译器只在Linux上是免费的，现在Windows和macOS上也有免费[安装包下载](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html)了，有在线安装和离线安装包2种，根据自己网络情况下载后安装，然后从开始菜单找到`Intel oneAPI command prompt for Intel 64 for Visual Studio 2019`，它的工具命令行是`icx`，但后面接了`clang`，所以也是`clang-cl`，这点不需要关心，知道是这回事就行，命令行如下：

```txt
mkdir build
cd build
cmake.exe -DCMAKE_BUILD_TYPE=Release -G"NMake Makefiles" -DCMAKE_PREFIX_PATH=U:\boost_1_77_0  -DCMAKE_CXX_COMPILER=icx  ..
nmake
```

用Intel oneAPI编译出来的可执行文件相比MSVC和官方Clang编译出来的可执行文件多链接了一个`libmmd.dll`，可能这是Intel家特有的一个优化点。

### GCC/Clang with MinGW

MinGW在Windows上有32位和64位两套环境，每套环境又有GCC和Clang这2组C++编译器，CMake都支持了这总共4种编译套件，构建工具可以使用MinGW官方的`mingw32-make`，注意一定要用官方CMake包，不要用msys2中的CMake，会有奇怪的问题。

#### 64位GCC

```txt
mkdir mingw64-gcc-build
cd mingw64-gcc-build
env PATH=$PATH:/mingw64/bin cmake.exe -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=gcc -DCMAKE_MAKE_PROGRAM=/mingw64/bin/mingw32-make.exe ..
env PATH=$PATH:/mingw64/bin /mingw64/bin/mingw32-make.exe -j `nproc` 
```

#### 64位Clang

```txt
mkdir mingw64-clang-build
cd mingw64-clang-build
env PATH=$PATH:/mingw64/bin cmake.exe -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang -DCMAKE_MAKE_PROGRAM=/mingw64/bin/mingw32-make.exe ..
env PATH=$PATH:/mingw64/bin /mingw64/bin/mingw32-make.exe -j `nproc` 
```

#### 32位GCC

```txt
mkdir mingw32-gcc-build
cd mingw32-gcc-build
env PATH=$PATH:/mingw32/bin cmake.exe -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=gcc -DCMAKE_MAKE_PROGRAM=/mingw32/bin/mingw32-make.exe ..
env PATH=$PATH:/mingw32/bin /mingw32/bin/mingw32-make.exe -j `nproc` 
```

#### 32位Clang

```txt
mkdir mingw32-clang-build
cd mingw32-clang-build
env PATH=$PATH:/mingw32/bin cmake.exe -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang -DCMAKE_MAKE_PROGRAM=/mingw32/bin/mingw32-make.exe ..
env PATH=$PATH:/mingw32/bin /mingw32/bin/mingw32-make.exe -j `nproc` 
```