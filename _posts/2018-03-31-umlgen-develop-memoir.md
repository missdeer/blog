---
layout: post
author: missdeer
title: "UMLGen开发踩坑"
categories: Shareware
description: UMLGen开发踩坑
tags: Qt
image: https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-03-31/mainwindow2.png
---

最近这段时间都在写一个叫UMLGen的GUI程序，从名字可以看出，就是一个用来画UML图的工具，与大多数现有的WYSIWYG（所见即所得）的UML画图工具（比如Visio，StarUML等等）不同的是，UMLGen使用代码的形式来描述UML图的呈现，与LaTeX的思想类似，即WYTIWYG（What You Think Is What You Get，所想即所得），我个人认为这种方式特别适合程序员使用。现在可用性已经很好了，主窗口截图如下：

![UMLGen main window](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-03-31/mainwindow2.png)

程序是用Qt写的，开发过程中还是遇到一些坑，记录一下。

* QtSvg模块实现的SVG标准有限，不能支持某些SVG，比如下面两张图，使用Firefox或Chrome浏览器查看，一切正常，用QtSvg则惨不忍睹。

![math](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-03-31/math.svg)

![math error](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-03-31/math-error.png)

![latex](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-03-31/latex.svg)

![latex error](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-03-31/latex-error.png)

除了换个支持完整的SVG库，就只能在这些时候不用SVG，改用PNG了。用PNG格式的问题是后端导出的PNG格式都是带白色背景的，而SVG是无背景透明的，这是我情愿尽量使用SVG格式的原因。

* 用Scintilla编辑代码，自己写了一个简单的lexer，因为支持了多个后端，于是就有多种语法，所以在一个lexer里要同时支持多种语法，就会有坑，现在暂时也没想实现得多完美，这个留待以后版本改进。

* Scintilla的Qt port对XPM图片格式支持有问题。XPM文件用文本编辑器打开可以看到是一个`const char *[]`的变量声明及初始化，但Scintilla的Qt port在register image时接收的参数被改成`const char *`，于是就对不齐了。