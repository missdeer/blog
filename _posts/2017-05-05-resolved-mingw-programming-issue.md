---
layout: post
title: "几个使用MinGW开发遇到的问题"
categories: CPPOOPGPXP
description: 解决了几个使用MinGW做开发遇到的问题
tags: MinGW
---

之前提到过我用MinGW版本的Qt遇到几个问题，现在基本解决。

* 不能编译Lua源代码。我在日志查看程序中嵌入Lua解释器来实现扩展功能，图省事把所有Lua源代码都拷到工程中，跟程序源代码一起编译，但在用MinGW编译时会报一些错误：

  ```
  D:\Works\dev\cjlv\3rdparty\lua-5.3.3\src\lobject.c:286: error: 'strcpy_instead_use_StringCbCopyA_or_StringCchCopyA' undeclared (first use in this function)
       strcpy(buff, s);  /* copy string to buffer */
       ^
  D:\Works\dev\cjlv\3rdparty\lua-5.3.3\src\luaconf.h:593: error: 'sprintf_instead_use_StringCbPrintfA_or_StringCchPrintfA' undeclared (first use in this function)
   #define l_sprintf(s,sz,f,i) ((void)(sz), sprintf(s,f,i))
                                            ^
  ```

  这个问题可以通过在`#include <strsafe.h>`前定义一个宏`STRSAFE_NO_DEPRECATE`解决，比较简便的方式是在.pro文件中直接全局定义：`DEFINES += STRSAFE_NO_DEPRECATE`。

  解决了这个问题后，重新编译，会遇到另一个错误：

  ```
  D:\Works\dev\cjlv\3rdparty\lua-5.3.3\src\lundump.c:88: error: conflicting types for 'LoadStringW'
   static TString *LoadString (LoadState *S) {
                   ^
  ```

  这是因为Lua源代码中定义的函数名`LoadString`跟Windows SDK中的宏LoadString冲突了，可以通过在lundump.c文件开头处添加：

  ```
  #ifdef _WIN32
    #pragma push_macro("LoadString")
    #undef LoadString
  #endif
  ```

  结尾处添加：

  ```
  #ifdef _WIN32
    #pragma pop_macro("LoadString")
  #endif
  ```

  即可解决。

* 编译时找不到`SHGetKnownFolderPath`定义。这个API[在Vista及以上版本的Window中存在](https://msdn.microsoft.com/en-us/library/windows/desktop/bb762188(v=vs.85).aspx)，可以通过宏定义当前系统版本号解决：`DEFINES += WINVER=0x0600 _WIN32_WINNT=0x0600`。

* 链接时找不到`IID_IImageList`符号定义。网上说这个符号定义在uuid.lib中，但我在命令行参数中已经加了`-luuid`仍然报错，后来看到有人自己写一个也能工作：

  ```cpp
  #if !defined(_MSC_VER)
      // For MinGW:
      static const IID iID_IImageList = {0x46eb5926, 0x582e, 0x4017, {0x9f, 0xdf, 0xe8, 0x99, 0x8d, 0xaa, 0x9, 0x50}};
      HRESULT hResult = SHGetImageList(imageListIndex, iID_IImageList, (void**)&imageList);
  #endif
  ```

* 没有QtWebEngine。这个实在没办法了，Chroumium这个上游项目就不支持MinGW，Qt也无能为力。不过今天看到有个[非官方的QtWebkit](https://github.com/annulen/webkit/releases)支持MinGW，实在需要的话可以试试。

----

另外，通过msys2安装的Qt可以直接使用msys2安装的库，比如quazip依赖的zlib，可以直接使用`pacman -S mingw-w64-x86_64-zlib`安装，之后`LIBS += -lz`即可，其他的诸如Boost，Lua之类的也可以如此直接使用。

----

最后我想说的是，用MinGW编译出来的程序运行起来似乎比用MSVC编译出来的程序运行要慢，肉眼可见的慢。