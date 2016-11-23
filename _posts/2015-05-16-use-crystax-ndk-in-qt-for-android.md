---
layout: post
title: "Qt for Android中使用CrystaX NDK替换官方Android NDK"
categories: Coding
description: Qt for Android中使用CrystaX NDK替换官方Android NDK
tags: Qt Android NDK CrystaX
---
昨天突然又想在Qt for Mobile中用上Boost，于是先得把Boost编译到iOS/Android上，然后发现了一个叫[CrystaX NDK](https://www.crystax.net/en/android/ndk)的东西，它本身的可以作为官方Android NDK的替代，不但对标准库和编译器有了一些改进，还包含了预编译好的Boost库。

根据CrystaX NDK网站上的介绍，它有以下一些关键特性：

- 完整的宽字符支持
- 完整的C locale支持
- 完整的math库支持，包括复数和泛类型的math函数
- 最新的工具链，我看了下其实也只有gcc 4.9，还没有clang，不知道它新在哪里？
- C++11/C++14支持，这点大概得益于作者所说的最新的工具链，但其实我看现在Android NDK r10d也有gcc 4.9和clang 3.5，这个应该也不在话下
- 完整的C++标准库支持。这个倒是确实Android NDK阉割了一部分。
- Boost库，我就是冲着它去的，貌似要用Android NDK编译Boost要先给Boost打些patch才行，它这个已经编译好的可以省一些时间
- Objective C和Objective C++支持，目前只支持了core，其实我也没想到在Android上用OC的场景，但在QQ群里跟一位用Qt for Mobile的资深开发谈时，他说可以先用OC写给iOS，然后再交叉编译到Android做移植。我还是没想明白这个！
- C标准库的很多修正和改进。这点如果是真的，倒是很有意义。
- 还有其他待加入特性

既然CrystaX NDK号称是a drop-in replacement of Google's Android NDK，那用起来应该是很简单才对，哪怕是在Qt中使用。

首先，在Qt Creator中选择菜单Preferences - Android，把Android NDK location设置到CrystaX NDK解压出来的目录中，假设是`~/crystax-ndk-10.1.0`。

然后，在终端下输入以下命令：

```bash
cd ~/crystax-ndk-10.1.0/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi-v7a
ln -s ../../../../../crystax/libs/armeabi-v7a/libcrystax.so libcrystax.so
```

这是因为Qt for Android在链接会有`-lcrystax`选项，但却没有把这个so所在路径添加到库搜索路径中，所以简便起见我就直接在Qt会搜索的路径中给这个so建个软符号链接。

最后还有一个问题要解决，就是`libcrystax.so`需要一起打包进APK中，这有两个办法：

1. 在Qt Creator的Projects页，Build Android APK区，可以添加Additional Libraries，把这个so添加过去应该就可以了。其实就是在.pro文件中添加了一句：`ANDROID_EXTRA_LIBS = $$NDK_ROOT/sources/crystax/libs/$$ANDROID_TARGET_ARCH/libcrystax.so`
2. 或者，在`ANDROID_PACKAGE_SOURCE_DIR`目录下，根据你的项目的目标机器平台建立文件夹，比如`$(PROJECT)/android/libs/armeabi-v7a`，把`libcrystax.so`文件放到这个目录中就行了。这种方法的缺点是要多复制一个文件，比较累赘。

这样就像官方Android NDK那样直接编译，链接，部署和运行了。
