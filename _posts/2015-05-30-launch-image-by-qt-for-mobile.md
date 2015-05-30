---
layout: post
title: "Qt for Mobile程序设置启动图片"
categories: coding
description: "Qt for Mobile程序设置启动图片"
tags: Qt iOS Android
---
Qt for Mobile默认是用了一张纯黑的图片作为程序启动图片，所以一开始程序启动时会出现1到几秒的黑屏，机器越慢，这个时间越长，比较不美观，我们可以自己动手设置上适合的图片。

移动app的启动图片在iOS上叫launch image，在Android上叫splash screen，在[istkani](https://itunes.apple.com/cn/app/istkani-le-tou-xing-cai-piao/id841279537)上都用上了。

在iOS上传统的做法，可以在Xcode上分别为第一种屏幕设置launch image。但是由于Qt for Mobile的特殊性，一旦用qmake重新生成了xcodeproj bundle，那些修改就丢失了，要再设置一遍，这样就比较麻烦。其实是有一劳永逸的办法的：

- 首先，按Apple的要求生成各个屏幕对应launch image文件，文件名也要统一按要求的来，如图![](/media/2015-05-30/ioslaunchimagefiles.png)
- 然后，在Info.plist中设定launch image的文件名前缀

```xml
    <key>UILaunchImageFile</key>
    <string>istkani</string>
```

- 接着，在.pro文件中让qmake生成对应的设置

```
ios {
    LaunchImages.files=$$system("find $$PWD/launchimage/ios/ -name '*.png'")
    LaunchImages.path=./
    QMAKE_BUNDLE_DATA += LaunchImages
    QMAKE_INFO_PLIST = iosInfo.plist
}
```

- 最后，运行qmake重新生成xcodeproj bundle就可以了，不用再在Xcode里设置什么。

在Android上是另外一种方法。

- 首先，把图片文件放在android/res/drawable目录下，如图![](/media/2015-05-30/androidspalshscreen.png)
- 然后，在android/res/layout目录下创建一个splash.xml文件，内容为

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    android:layout_gravity="center"
    >
    <ImageView
        android:layout_width="fill_parent"
        android:layout_height="fill_parent"
        android:src="@drawable/logo"
        android:scaleType="fitXY"
        />
</LinearLayout>
```

- 接着，修改android/AndroidManifest.xml文件，在第一个Activity节点处添加一个meta-data节点，注意`android:resource`属性要与第一步添加的图片文件名一致

```xml
<meta-data android:name="android.app.splash_screen_drawable" android:resource="@drawable/logo"/>
```

- 再次修改.pro文件，让qmake知道去哪找android目录

```
android: {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += $$PWD/android/AndroidManifest.xml
}

```

- 最后运行一下qmake，Android上的Splash screen也设好了。