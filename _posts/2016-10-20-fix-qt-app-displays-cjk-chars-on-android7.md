---
layout: post
title: "修正Qt app在Android 7上显示中文字符"
categories: Coding
description: 修正Qt app在Android 7上显示中文字符
tags: Qt Android
---
今天手头上的Nexus 6通过OTA升级到了Android 7，之后发现几个用Qt写的App显示中文字符全变成方块了。这个问题在当时系统刚升级到6.0时也遇到过，解决办法是自己带一个中文字体，再在程序中指定使用这个中文字体。这是比较繁琐的解决方法，Qt官方也收到了[问题报告](https://bugreports.qt.io/browse/QTBUG-53511)，只不过修正后的版本还没有发布，但是问题报告下面有人提到了问题代码，所以要自己出个workaround也很容易，只要在自己的程序开头加这么一段代码就可以了：

```cpp
    QDir dir("/system/fonts");
    const auto entries = dir.entryInfoList(QStringList() << "*.ttc" << "*.ttf" << "*.otf", QDir::Files);
    for (const QFileInfo& fi: entries)
    {
        qWarning() << fi.absoluteFilePath();
        QFontDatabase::addApplicationFont(fi.absoluteFilePath());
    }
```

另外顺便提一下，Qt要指定font family fallback其实并不复杂，之前还花了不少时间找到的：

```cpp
    QFont font(qApp->font());
    listFonts << "Droid Sans" << "Source Han Sans" << "Noto Sans";
    font.insertSubstitutions(font.family(),listFonts);
    qApp->setFont(font);
```

再另外，macOS上JDK可能会有多个，javac可能有多个，其实只要在`/Library/Java/JavaVirtualMachines/`下面找就行了，选个最高的版本号，比如`/Library/Java/JavaVirtualMachines/jdk1.8.0_40.jdk/Contents/Home/`，Qt Creator上编译Android app需要设置这个Home路径。
