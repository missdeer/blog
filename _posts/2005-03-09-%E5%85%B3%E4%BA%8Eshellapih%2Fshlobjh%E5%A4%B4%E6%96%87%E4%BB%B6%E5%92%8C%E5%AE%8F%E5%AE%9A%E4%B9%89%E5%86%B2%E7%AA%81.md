---
layout: post
title: 关于shellapi.h/shlobj.h头文件和宏定义冲突
categories: 
 - imported from CSDN
description: 关于shellapi.h/shlobj.h头文件和宏定义冲突
tags: 
---

昨天在给LLYF ProcessHelper添加TrayIcon功能，代码是从LLYF Spy 那部分完全Paste 过来的，结果编译的时候说`NIF_INFO`没有定义，还有`szInfo`、`uTimeout`这些凡是说要IE Version5.0 以上支持部分都说没有定义，可是我在LLYF Spy 里好好的呀，还以为是XP 的问题，马上退到2000 下，结果一样。于是我打开ShellApi.h看，在那个函数和结果定义前加上`#define _WIN32_IE 0x0600`，编译是勉强通过了，但是功能没有实现，并没有Balloon ToolTip 出现。后来在看Project Options，发现有个`NO_WIN32_LEAN_AND_MEAN`定义，是因为有一个函数里调用了SHBrowseForFolder，要加shlobj.h 这个头文件，于是意识到可能和这个有关。搜索了一下，我的程序里并没有调用到这个函数（我晕），于是把这个函数体全部注释掉，把这个头文件和宏也删了，编译和运行都正常了。

但这样还是不满意撒，不能同时用Balloon Tooltip 和SHBrowseForFolder 了，后来上google 搜了一下，发现有一个解决办法，头文件和宏定义的顺序换下就行了：

```cpp
#define NO_WIN32_LEAN_AND_MEAN
#include <ShlObj.h>
#include <VCL.h>
```

严格按照这个顺序，后面再include 其它的ShellApi.h 之类的都可以了。
