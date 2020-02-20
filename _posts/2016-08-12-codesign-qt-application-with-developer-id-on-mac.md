---
layout: post
image: https://img.peapix.com/13377862310612361138_320.jpg
author: missdeer
title: "在Mac上给Qt程序用Developer ID签名"
categories: Qt
description: 在Mac上给Qt程序用Developer ID签名
tags: Qt Mac 
---
最近想着赶紧弄个程序出来上架到Mac App Store去，因为我只会用Qt写Mac的GUI程序，所以要研究一下如何把Qt程序签名上架，结合网上找到的[这篇](www.sollyu.com/mac-qt-program-released/)、[这篇](http://blog.qt.io/blog/2012/04/03/how-to-publish-qt-applications-in-the-mac-app-store-2/)，以及[这篇](http://blog.qt.io/blog/2014/10/29/an-update-on-os-x-code-signing/)文章，折腾了几天了，最终，仍然没搞定怎么签能上架Mac App Store的Qt程序，貌似只搞定了Developer ID类型的，即在Mac App Store以外发布的程序，这种签名唯一的用处貌似是别人拿去能直接运行而不会弹出个消息框说来自不受信任的开发者（其实我是猜的，没验证过。

算了，先把这个步骤记录一下。

1. 首先，当然是得有Apple开发者账号，然后在后台创建好App ID和证书，这App ID对Developer ID类型的是否必须我也不确定，但要上Mac App Store肯定是需要的，证书我只管Production类型里Developer ID和Mac App Store两种，创建好后下载到本地，点击下载到的.cer文件自动导入到Keychain中，这时在Keychain的login-My Certificates分类里可以看到新导入的证书，关注证书的名称，后面签名时要用到，如果copy不出来（我就遇到了，右键菜单怎么点都没用），就用命令行`certtool y | grep ": <YourName> "`，会列出本机安装的所有开发发布用的证书。如果是用Xcode，就不用记，Xcode会自动获取，但我后面是用命令行的，没办法。
2. Qt程序编译好之后，用`macdelpoyqt`命令把Qt的各个Framework都copy到程序的bundle中，加参数`-appstore-compliant`可以跳过Mac App Store不兼容的那些lib。
3. 据说，如果发布到Mac App Store，是要用Sandbox的，要用Sandbox的话，就得在一个entitlements文件中设置一些权限，比如说用户可以选择本机的文件进行读写之类的（好严格）。这个entitlements文件可以用Xcode随便创建个新工程，然后在Targets-Capabilities里设置然后就自动生成一个.entitlements为后缀的文件了。
4. 最后，命令行`codesign -s "Developer ID Application: Your Name (XXXXXX)" -v --timestamp=none --entitlements MyApp.entitlements -f --deep MyApp.app`对app签名。其中，`-s`指定证书名称，就是第1步列出来的那些证书中的选择Developer ID的一个，`-v`表示输出详细信息，`--timestamp`我也不清楚具体什么作用，这么写就行，`--entitlements`指定第3步生成的那个.entitlements文件，`-f`指可以覆盖原有的签名，`--deep`使得app bundle内的所有能签名的Framework都会被分别签名。

到此，签名算是完成了，可以通过命令`spctl -a -v MyApp.app`进行验证，如果签名成功了，大概会输出诸如此类的信息：

```
MyApp.app: accepted
source=Developer ID
```

不然就可能是这样的：

```
MyApp.app: rejected
source=no usable signature
```

原本我以为只要把证书换成Mac App Store的，就能签名成功并去上架Mac App Store了，结果用`spctl`看一直是rejected的，这个问题就要再研究了。
