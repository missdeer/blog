---
layout: post
title: "imchenwen进度：优化"
categories: Shareware
description: imchenwen进度：优化
tags: Qt imchenwen
---

这段时间主要是做了些优化。

终于找到了“关于”和“偏好设置”没有国际化的原因，需要装入`qt_*.qm`文件，比如简体中文则是`qt_zh_CN.qm`，在mac上运行`macdeployqt`并不会复制这些qm文件，Windows上的`windeployqt`则会复制一些其他语言的，但没有中文的。

![Application menu](../../../media/2018-12-01/aboutmenu.png)

增加了“解析并播放视频”的菜单项，主要是想增加快捷键，并对用户明显，所以就加到主菜单去了。

![Application menu](../../../media/2018-12-01/playmenu.png)

在“快捷方式”菜单中增加了“在线电影”的分类，国内网上有很多在线看电影的网站，都是通过Flash播放在线视频资源，很多热门资源可以直接观看。

![Application menu](../../../media/2018-12-01/shortcut.png)

调整了“偏好设置”对话框，在顶部增加了一个图标工具栏。QDialog并不能在Qt Designer中直接拖拽增加一个工具栏，但可以通过代码增加，所以我的方法是在顶部放一个空的占位QWidget，然后在代码中用QToolBar替换掉，代码如下：

```cpp
QToolBar* toolbar = new QToolBar(this);
layout()->replaceWidget(widgetPlaceholder, toolbar);
toolbar->setIconSize(QSize(48, 48));
toolbar->setToolButtonStyle(Qt::ToolButtonIconOnly);
```

效果如下：

![Application menu](../../../media/2018-12-01/configuration.png)

