---
layout: post
author: missdeer
title: "对Go不够熟练"
categories: Go
description: 使用Go语言编写代码不够熟练
tags: Go PuTTY OpenSSH Xshell SecureCRT
---
虽然使用Go语言写东西已经有一段时间了，但仍然不是很熟练，一些常见的用法仍然要不停地翻官方文档和搜以前写过的代码。前些天用Go的zlib包对数据进行压缩再传输，发现小数据量，比如4MB以下，总是压出结果只有2字节，这是明显有问题，实际上大点的数据量，比如5MB或更多，虽然压出的结果不是2字节了，但现在想来也是有问题的。看了很多网上的代码，发现跟我的几乎没区别。最后偶然才发现，原来是得到一个io.Writer写完后就马上关闭，再去看压缩后的结果，那时就是正确的，而我之前一直是在关闭前就去取结果了。

说点题外话。之前一直是用PuTTY，最近发现在家里那台式机上通过http代理连公司的机器时，刷新屏幕是整个窗口一闪一闪的，速度很慢。在Cygwin里用OpenSSH也是差不多。然后试了下韩国产的Xshell，要好一点，最后试了一下网上口碑最好的SecureCRT，果然是几个里最快最好的。商业软件很多时候确实质量要比开源软件好啊！好在SecureCRT现在Windows，Mac，Linux都有了，果断全部换上，至于license，我惭愧，我忏悔，我呵呵。又试了几个字体4，包括Consolas，Monaco，SourceCode Pro等等，最后发现还是Mac自带的Menlo最舒服，果断在其他系统上都装一份。
