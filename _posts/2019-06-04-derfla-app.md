---
layout: post
image: https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/everything.png
author: missdeer
title: "Derfla，快捷应用启动器"
categories: Shareware
description: "Derfla，快捷应用启动器"
tags: Qt Alfred Derfla
---

这是好几年前就开的坑，当年是对标[Launchy](https://www.launchy.net/)，后来推翻重写，想对标[Alfred](https://www.alfredapp.com/)，到目前为止，也仅仅是完成了很少几个功能，很多精力和时间都花在UI上了。一开始是照Launchy的完全图片自绘，最近加上了Alfred风格的UI。

主要特色包括：

1. 比较灵活的扩展性。通过Extension机制，从外部进程获取扩展的信息和功能，通过标准输出的管道获取内容。相对来说运行效率略低，但不会受限于固定的编程语言、框架等等，同时扩展进程崩溃不会影响Derfla主进程。每个Extension有一个配置文件描述相关信息，示例如下：

   ```lua
   id= "com.derfla.hashdigest"
   author= "missdeer"
   name= "HashDigest"
   if derfla.os.name == "windows" then
   	executable= "hashdigest.exe"
   else
   	executable= "hashdigest"
   end
   
   description= "Calculate hash digest of string, file..."
   prefix={"md4", "md5", "sha1", "sha224", "sha256", "sha384", "sha512", "sha3-224", "sha3-256", "sha3-384", "sha3-512", "keccak224", "keccak256", "keccak384", "keccak512"}
   waitIconPath= ""
   waitTitle= "Calculating..."
   waitDescription= "Calculating..."
   ```

   

2. 比较灵活的可定制UI。目前有Alfred风格UI和Launchy风格UI两种，每种都可以通过配置文件进行定制。其中Alfred风格UI定制被称为theme，示例如下：

   ```lua
   beginHeight = 125
   listWidgetY = 91
   dimensions = { width = 550, height = 75 }
   groupBoxStylesheet = "QGroupBox{background:white;border-radius: 9px;}";
   plainTextEditStylesheet = "QPlainTextEdit{border: 1px solid white}";
   listWidgetStylesheet = "QListWidget{border: 1px solid white} QListWidget::item{padding : 3px 3px 3px 3px}";
   
   if derfla.os.name == "macos" then
       fontSize = 52;
   else
       fontSize = 40
   end
   
   blurRadius = 9.0;
   shadowColor = { r = 0, g = 0, b = 0, a = 160 }
   shadowOffset = 3.0;
   ```

   Launchy风格UI定制为称为skin，示例如下：

   ```lua
   image = "derfla.png"
   inputstyle = [[
   QLineEdit { font: 48px;
   	border-width: 0px;
   	background-color: rgba(0,244,120,0%);
   	border-style: solid;
   	color: white;
   	qproperty-alignment: AlignLeft;
   	qproperty-geometry: rect(46 62 375 68); }
   ]]
   ```

   其中`derfla.png`是同目录中的一个图片文件：

   ![derfla.png](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/derfla.png)

   目前两种风格的UI在业务行为上还没有完全统一，需要继续改进。

3. 基于Lua语言的配置文件格式，theme、skin、extension的配置全部使用Lua语言编写。优点是可以通过当前具体环境进行特定的配置，比如Windows下的可执行文件名是以`.exe`结尾，其他平台都没有这个后缀，又比如在不同平台上要使用不同大小的字体才能获得相近的视觉效果等等。同时也可以从主程序侧（C++）暴露一些接口给Lua侧使用。缺点是运行期修改不方便。

4. 主程序使用Qt/C++编写，所以支持在Windows、macOS、Linux等系统上运行。

Roadmap：

1. 更多的extension，提供更丰富实用的功能。
2. Plugin机制，扩展主程序的核心功能。比如目前主程序UI只有list一种展示方式，能展示的内容也很有限，可以通过Plugin实现更多展示功能，比如预览条目内容，像条目是PDF或PNG之类的文件，完全可以新开一个窗口进行实时预览。Plugin不同于extension，将是以动态库的形式插入到主程序进程中运行。
3. 系统事件监控及hook接口，对标[Hammerspoon](http://www.hammerspoon.org/)。

最后贴几张screenshot。

Everything搜索文件或目录：

![everything.png](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/everything.png)

打开搜索引擎：

![se.png](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/se.png)

计算器：

![calc.png](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/calc.png)

快捷应用启动：

![lfs.png](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/lfs.png)

Hash计算：

![md5.png](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/md5.png)

天气：

![weather.png](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/weather.png)

有道词典

![dict.png](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2019-06-04/dict.png)