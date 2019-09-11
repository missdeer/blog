---
layout: post
author: missdeer
title: "imchenwen进度：优化"
categories: Shareware
description: imchenwen进度：优化
tags: Qt imchenwen
---

这段时间主要是做了些优化。

终于找到了“关于”和“偏好设置”没有国际化的原因，需要装入`qt_*.qm`文件，比如简体中文则是`qt_zh_CN.qm`，在mac上运行`macdeployqt`并不会复制这些qm文件，Windows上的`windeployqt`则会复制一些其他语言的，但没有中文的。

![Application menu](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-12-01/aboutmenu.png)

增加了“解析并播放视频”的菜单项，主要是想增加快捷键，并对用户明显，所以就加到主菜单去了。

![play menu](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-12-01/playmenu.png)

在“快捷方式”菜单中增加了“在线电影”的分类，国内网上有很多在线看电影的网站，都是通过Flash播放在线视频资源，很多热门资源可以直接观看。

同时修改了视频地址嗅探操作方式，原本VIP类型的视频需要自己一个一个尝试使用解析网站获取视频地址，这样比较低效和麻烦，现在另外新开一个进程，单独嗅探某个URL下的视频地址，所以可以并发多个解析网站进行解析嗅探，另一个好处是也可以在后台嗅探在线电影网站的视频地址嗅探了。

另一个改动是把“快捷方式”的网站定义和VIP视频解析网站地址都写到网上了，每次程序启动从网上加载列表，所以列表可以自定义，这就很灵活了，特别是VIP视频解析网站可能变化很频繁，用户也可以自己维护一个列表。

![shortcut menu](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-12-01/shortcut.png)

调整了“偏好设置”对话框，在顶部增加了一个图标工具栏。QDialog并不能在Qt Designer中直接拖拽增加一个工具栏，但可以通过代码增加，所以我的方法是在顶部放一个空的占位QWidget，然后在代码中用QToolBar替换掉，代码如下：

```cpp
QToolBar* toolbar = new QToolBar(this);
layout()->replaceWidget(widgetPlaceholder, toolbar);
toolbar->setIconSize(QSize(48, 48));
toolbar->setToolButtonStyle(Qt::ToolButtonIconOnly);
```

效果如下：

![configuration](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2018-12-01/configuration.png)

