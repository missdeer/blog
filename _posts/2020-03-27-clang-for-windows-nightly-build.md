---
image: https://cdn.jsdelivr.net/gh/missdeer/blog@master/media/2020-03-27/llvm.png
layout: post
author: missdeer
featured: false
title: "用上Clang for Windows Nightly Build"
categories: CPPOOPGPXP
description: "用上Clang for Windows Nightly Build"
tags: Clang
---

Clang for Windows早已经可堪实用，官方每隔一个月或几个月会发一个编译好的[snapshot](https://prereleases.llvm.org/win-snapshots/)外，msys2项目也提供了不是特别新的版本（目前9.0.1）可以直接通过pacman安装使用。作为一个升级控，用上Nightly Build岂不是更爽！当然这不是官方的，而是需要自己下载源代码进行编译。

编译Clang非常简单。首先，从git仓库下载必须部分的源代码，为节省时间可以不下载历史记录：

```shell
git clone --depth=1 https://github.com/llvm/llvm-project.git
```

然后，准备好构建工具[ninja](https://github.com/ninja-build/ninja)：

```shell
pip install ninja2
```

还需要cmake，从[官网](https://cmake.org/download/)下载解压即可。

最后，使用MSVC的命令行环境进行编译，加入一些参数只编译需要的部分：

```
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %vc_arch%
mkdir -p llvm-project\build
cd llvm-project\build
cmake.exe -GNinja -DCMAKE_BUILD_TYPE=release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_C_FLAGS="/utf-8" -DCMAKE_CXX_FLAGS="/utf-8" -DCMAKE_INSTALL_PREFIX=llvm_win_bin -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON ..\llvm
ninja
ninja install
```

如果一切顺利的话，经过漫长的等待，视机器配置而定，短则2，3个小时，长则时间再翻倍，最后可以得到包括`clang.exe`，`clang++.exe`，`clang-cl.exe`在内的一系列编译程序，它可以配合MSVC的头文件、库文件使用。

另外需要注意的是，x86_64版本的clang可能需要`vcruntime140_1.dll`这个文件才能正确运行，随便从其他地方找一个放到`clang.exe`所在目录即可。

到此为止已经验证可以自己编译Clang for Windows，要nightly build的话，就自己找个每天开机足够长时间的机器，定时触发下载代码和编译即可。所以我就打上了Github Actions的主意，自从微软收购了Github，频频表现出财大气粗的土豪气质，Github Actions免费使用，每个job最长6个小时，还提供不知道到底有多大的artifacts存储空间，刚好适用于做Clang for Windows的nightly build。

在Github上新建一个[仓库](https://github.com/missdeer/clang-for-windows-daily-build)，名字什么的都随意，在仓库中新建一个文件`.github/workflows/windows.yml`，写入如下内容：

```yaml
name: Windows
on: 
  schedule:
    - cron:  '0 18 * * *'
  push:
    paths-ignore:
      - 'README.md'
      - 'LICENSE'
  pull_request:
    paths-ignore:
      - 'README.md'
      - 'LICENSE'
jobs:
  build:
    name: Build
    runs-on: windows-latest
    strategy:
      matrix:
        msvc_arch: [x64, x86]
    env:    
      {% raw %}targetName: llvm-win-${{ matrix.msvc_arch }}{% endraw %}    
    steps:
      - name: Checkout llvm-project
        shell: cmd
        run: |
          git clone --depth=1 https://github.com/llvm/llvm-project.git
      - name: build-msvc
        shell: cmd
        env:        
          {% raw %}vc_arch: ${{ matrix.msvc_arch }}{% endraw %}        
        run: |
          call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %vc_arch%
          mkdir -p llvm-project\build
          cd llvm-project\build
          cmake.exe -GNinja -DCMAKE_BUILD_TYPE=release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_C_FLAGS="/utf-8" -DCMAKE_CXX_FLAGS="/utf-8" -DCMAKE_INSTALL_PREFIX=llvm_win_bin -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON ..\llvm
          ninja
          ninja install
      - name: upload artifact
        uses: actions/upload-artifact@v1
        with:
          path: llvm-project\build\llvm_win_bin\bin          
          {% raw %}name: llvm-win-${{ matrix.msvc_arch }}{% endraw %}          
```

这个workflow实现了这些功能：

1. 每天UTC时间18:00自动触发，或有push，或merge pull request时触发编译
2. 使用最新的Windows系统镜像，目前是Windows Server 2019
3. 针对x86和x64两种架构进行编译
4. 编译后的目标名称是`llvm-win-x86`和`llvm-win-x64`
5. 只从llvm官方git仓库下载最新的代码
6. 使用cmake，ninja，msvc进行最后的编译，如上所述
7. 将编译生成的bin目录上传到artifact上，以后可以从Github网站下载

根据我的实际使用经验，2个job的artifact每个都有1GB左右，`actions/upload-artifact@v1`会自动用zip压缩一下，最后是400-500MB大小。根据网上各种不明确的信息来看，每个用户或每个仓库可用的artifact存储空间其实是有限的，像我们这种每天1GB左右的用法估计没几天就会触顶了，所以我又另外写了个[程序](https://github.com/missdeer/cicdutil)，调用Github API操作artifact，每天定时执行删掉旧的artifact，只保留最新的2个artifacts，获取最新的2个artifacts的下载链接，调用curl或aria2或wget下载，这样就实现每天用上最新的Clang for Windows nightly build的目标了。