---
layout: post
image: https://img.peapix.com/17381825925308634288_320.jpg
author: missdeer
title: "QML元素在Android上的Scaling"
categories: Qt
description: QML元素在Android上的Scaling
tags: QML QtQuick Android Scaling
---
这两天突然想把[istkani](https://itunes.apple.com/cn/app/istkani-le-tou-xing-cai-piao/id841279537)在Android跑一下，本来是想集成个[腾讯信鸽](http://xg.qq.com/)的推送功能，但是信鸽没集成好（程序老是挂掉），先去调了一下界面的问题。

目前我手头有了Nexus S，Nexus 6和Nexus 7第一代可供调试，QML写的程序在不同屏幕上表现真是千差万别，元素的大小和字体的大小不经过自己计算，默认直接用上去效果惨不忍睹。虽然在iOS上也需求自己稍微调整一下，但没Android上那么夸张。

首先，有两个公式，可以得到一个ratio和一个scale factor，如下：

```cpp
    QRect rect = qApp->primaryScreen()->geometry();
    m_ratio = m_isMobile ? 
    			qMin(qMax(rect.width(), rect.height())/1136. , qMin(rect.width(), rect.height())/640.) : 
    			1;
#if defined(Q_OS_ANDROID)
    m_scaleFactor = qApp->primaryScreen()->physicalDotsPerInch() * 
    					qApp->primaryScreen()->devicePixelRatio() / 
    					160.;
#else
    m_scaleFactor = 1;
#endif
```

至于这两个公式怎么来的，我也不知道，我也不懂，我是从网上搜来的，关键是还真能用。可以看到Android平台的scale factor要再自己这么计算一下，貌似iOS平台上Qt自己内部处理了。

然后在QML中，字体大小通过`pixelSize`属性来控制，比如原本要设`20`，就设成`20 * ratio`，当然这`ratio`要从C++侧导出到QML侧。其他元素（比如Rectangle之类）的大小，则是乘上`scaleFactor`这个因子，比如`width`或`height`要设`20`，就设成`20 * scaleFactor`，同样要把`scaleFactor`从C++侧导出到QML侧去。

这样在3种设备上可以得到3组不同的值：

```
|    值\设备     | Nexus S  | Nexus 6   | Nexus 7第一代 |
| ------------- | ---      | ---       | ---          |
| ratio         | 0.704225 | 2.10563   | 1.06074      |
| scale factor  | 1.47106  | 3.08821   | 1.33264      |
```

直接看也没什么规律，反正就可以这么用了。从运行效果上来看，通过`ratio`计算出来的元素大小会以当前屏幕大小保持相对固定的比例，也就是说，不同屏幕上排满元素的话，元素个数几乎是相同的，元素大小是不同的。通过`scale factor`计算出来的元素大小几乎是跟屏幕大小和分辨率无关了，不同屏幕上显示的元素如果用物理上的尺子去丈量的话会得到相近的结果，也就是说不同屏幕上排满元素的话，元素个数大屏幕上的比小屏幕上的多。

这是我到目前为止观察到的结论。

------

另外顺便记个题外话。当时刚在Nexus 6上跑这个程序时，发现中文有一部分能显示有一部分会显示方块，在网上有人说是字体的问题，说Android 5默认用的是DroidSansFallback字体，大概QML默认没用这个字体，或者说我的机器上默认没这个字体要自己刷一个。总不能指望每个用户的手机上都有刷了字体吧，所以可以通过程序解决这个问题。

首先从网上下载一个DroidSansFallback.ttf文件，打包到qrc里，然后在程序开头加几行代码：

```cpp
#if defined(Q_OS_ANDROID)    
    int droidSansID = QFontDatabase::addApplicationFont(":/fonts/DroidSansFallback.ttf");
    QStringList loadedFontFamilies = QFontDatabase::applicationFontFamilies(droidSansID);
    if (!loadedFontFamilies.empty()) {
        QString fontName = loadedFontFamilies.at(0);
        QFont font(fontName);
        font.setPointSize(14); // 还可以顺便设个默认字体大小哦
        QApplication::setFont(font);
    } else {
        qWarning("Error: fail to load DroidSansFallback font");
    }
#endif
```

这样就可以正常显示中文了。
