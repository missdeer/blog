---
layout: post
title: "MSVC与Go语言混合开发"
categories: Go
description: MSVC与Go语言混合开发
tags: Go cgo
---

用C++写程序时，有些事情发现用Go做很容易，用C++则比较折腾，所以就想用Go实现，然后通过cgo链接到C++程序中。但是cgo在Windows上只能使用gcc实现，有时我又有必须使用MSVC的理由。

Go在Windows上可以直接用gcc生成静态库或动态库，但要让MSVC也能用上，需要做一些处理。

首先，生成静态库，比如：

```
set CGO_ENABLED=1
go build -buildmode=c-archive -o libgo.a main.go
```

然后，创建一个def文件，声明导出符号，比如`libgo.def`：

```
EXPORTS
    Function1
```

接着，用gcc从该def和静态库生成一个dll：

```
gcc libgo.def libgo.a -shared -lwinmm -lWs2_32 -o libgo.dll -Wl,--out-implib,libgo.dll.a
```

这时，应该已经有了一个`libgo.dll`文件和一个`libgo.def`文件，用MSVC自带的`lib`程序生成MSVC可用的`.lib`文件：

```
lib /def:libgo.def /name:libgo.dll /out:godll.lib /MACHINE:X86
```

如果是64位环境，则将最后一个参数改为`/MACHINE:X64`。

最后，修改Go编译器生成的`libgo.h`文件，将其中2行`line #1`开头的行删掉，2行`_Complex`相关的代码删掉。

这时，MSVC程序可以直接`#include "libgo.h"`，代码中可以直接调用函数`Function1`，并在链接时添加对`godll.lib`的引用。

其实Go是可以直接生成dll文件的，但会把所有Go runtime的函数全部导出，略显冗余，所以我这里就通过自己创建的def文件来声明需要导出的函数。