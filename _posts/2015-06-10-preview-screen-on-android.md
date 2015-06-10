---
layout: post
title: "设置Android app的preview screen"
categories: coding
description: 设置Android app的preview screen
tags: Android Qt 
---
之前写过[一篇文章](/2015/05/launch-image-by-qt-for-mobile/)谈到为Android app设置splash screen，以避免Qt写的app启动时有一段时间黑屏。今天收到一位朋友的email询问，在splash screen之前仍然会有一个黑屏，怎么去除。

这个问题其实很好解决，这是Android系统本身的设计如此，跟Qt本无关系。这个splash screen前出现的黑屏叫preview screen，我们可以通过设置一个theme来定义它的外观，一般说来我们可以通过把它的窗口背景色设置成跟splash screen的背景色相同，来使得这2个screen切换过渡看起来比较自然。

比如我在[istkani](https://itunes.apple.com/cn/app/istkani-le-tou-xing-cai-piao/id841279537)上用splash screen是白色的背景色，于是需要添加一个文件 `$(PROJECT)/android/res/values/styles.xml`定义theme：

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:android="http://schemas.android.com/apk/res/android">
    <style name="istkaniTheme" parent="@android:style/Theme.Holo.NoActionBar">
        <item name="android:windowBackground">@android:color/white</item>
    </style>
</resources>
```

注意，其中`@android:color/white`就是设置的颜色值。

然后修改`$(PROJECT)/android/AndroidManifest.xml`，设置application的theme：

```xml
<application 
				android:name="com.dfordsoft.istkani.IstkaniApp" 
				android:label="@string/app_name" 
				android:icon="@drawable/icon" 
				android:theme="@style/istkaniTheme" >
......
```

注意，这里`@style/istkaniTheme`要与前面`styles.xml`中定义的style name一致。

经过以上两步，启动app时会先显示一个全屏的白色preview screen，然后立即显示一个在白色背景之上有图案的splash screen，让人感觉非常自然。