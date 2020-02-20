---
layout: post
image: https://img.peapix.com/10688545263026434123_320.jpg
author: missdeer
title: "为4个平台编译Boost"
categories: CPPOOPGPXP
description: 为Windows，macOS，Android，iOS平台编译Boost
tags: Boost
---

公司的项目至今仍在使用Boost 1.56.0版本，最近发现Boost.uuid在Windows上居然会一直尝试去访问`/dev/urandom`，进而转移到系统盘根目录`urandom`文件，然后客户认为这会有安全隐患，需要修正。我随手看了一下Boost.uuid在1.56.0和1.64.0上的源代码，貌似确实1.56.0版并没有分系统实现，在1.64.0上为Windows系统使用平台特有的实现。于是我就建议升级Boost，然后发现这个third party的owner居然是我们组，同事开玩笑地问我能不能去为几个平台编译一下Boost，我当场就拒绝了，但回到家我还是决定折腾一下。

* Windows平台使用msvc 2015的话[特别简单](https://gist.github.com/missdeer/b6b59df5f8dbd31297166671eb0b9ab7)：

{% gist b6b59df5f8dbd31297166671eb0b9ab7 %}

* macOS和iOS平台使用了同一组脚本，从网上找的，我再自己稍做修改，macOS上只要[x86_64架构](https://gist.github.com/missdeer/72d3fb3a5bc24d6737cfd30358adca6f)的即可。

{% gist 72d3fb3a5bc24d6737cfd30358adca6f %}

* iOS上需要armv7，arm64，i386，x86_64[四种架构](https://gist.github.com/missdeer/70446cefa67602e1c9800dc0b4ec6bc0)的。

{% gist 70446cefa67602e1c9800dc0b4ec6bc0 %}

* Android平台的搞了很久，昨天晚上折腾到12点多，今天又折腾了一个白天，终于搞定。网上有许多各种方案，在Linux，Windows，macOS上都有，我在Windows 10上折腾了很多次都不行，最后在macOS上成功了。首先，仍然是先构建bjam：

  ```shell
  ./bootstrap.sh
  ```

  然后修改Boost根目录下的`project-config.jam`文件，用以下内容覆盖文件内容：

  ```
  import option ;

  using gcc : x86 : i686-linux-android-g++ ;
  using gcc : x86_64 : x86_64-linux-android-g++ ;
  using gcc : mipsel : mipsel-linux-android-g++ ;
  using gcc : mips64el : mips64el-linux-android-g++ ;
  using gcc : aarch64 : aarch64-linux-android-g++ ;
  using gcc : arm : arm-linux-androideabi-g++ ;

  option.set keep-going : false ;
  ```

  接着把Android NDK路径设置到环境变量中：

  ```shell
  export androidNDKRoot=$HOME/android-ndk-r14b
  ```

  最后[运行bjam进行编译](https://gist.github.com/missdeer/488f5e01cd21ea072770e33325fc58eb)：

{% gist 488f5e01cd21ea072770e33325fc58eb %}

  这样可以编译出armeabi等共6种目前官方NDK支持的架构的静态库。
