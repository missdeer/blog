---
image: https://blogassets.ismisv.com/media/2022-08-17/qml.png
layout: post
author: missdeer
featured: false
title: "[机翻]优化QML应用程序，将其编译为C++"
categories: QML
description: "优化QML应用程序，将其编译为C++"
tags: QML Qt
---
> 原文链接：https://www.qt.io/blog/optimizing-your-qml-application-for-compilation-to-c

这是一系列帖子的开始，我将在其中分享一些关于如何调整 QML 应用程序以充分利用 QML 脚本编译器 qmlsc 的见解。与之前的帖子相比，我不会谈论抽象架构或高级图片。你可以在[我](https://www.qt.io/blog/qml-modules-in-qt-6.2?hsLang=en)[以前](https://www.qt.io/blog/the-new-qtquick-compiler-technology?hsLang=en)的[帖子](https://www.qt.io/blog/the-numbers-performance-benefits-of-the-new-qt-quick-compiler?hsLang=en)中阅读。相反，我将展示具体的代码片段以及如何更改它们的具体建议。

目前计划发布的文章有：

1. [JavaScript函数的类型注解](https://www.qt.io/blog/compiling-qml-to-c-annotating-javascript-functions?hsLang=en)
2. [编译期类型可见性](https://www.qt.io/blog/compiling-qml-to-c-making-types-visible?hsLang=en)
3. [鸭子类型的替代品](https://www.qt.io/blog/compiling-qml-to-c-avoiding-duck-typing?hsLang=en)
4. [解开依赖关系](https://www.qt.io/blog/compiling-qml-to-c-untangling-dependencies?hsLang=en)
5. [QtQuick.Controls及其可选导入](https://www.qt.io/blog/compiling-qml-to-c-qtquick-controls-and-optional-imports?hsLang=en)
6. [QML导入路径](https://www.qt.io/blog/compiling-qml-to-c-import-paths?hsLang=en)
7. [对组件根对象成员的无限制访问](https://www.qt.io/blog/compiling-qml-to-c-fixing-unqualfied-access?hsLang=en)

该列表可能会增长。我正在使用 Qt 的尖端功能。其中一些甚至可能尚未发布。在任何情况下，我都会说明应用给定技术所需的最低 Qt 版本。

如上所述，我们将在这里弄脏手。为了做到这一点，我们首先需要找到一个提供足够污垢的软件。

Qt Creator 的 QML Profiler 已经存在了一段时间，有些人可能已经忘记了它。让我向你保证，它仍然像往常一样工作。您可以衡量应用程序的性能，而且至关重要的是，它将衡量提前编译（ahead of time compilation）所获得的任何加速效果。然而，作为一个相当老的 QML 应用程序，QML 分析器 GUI 还不能很好地编译为 C++。让我们解决这个问题。在此过程中，我们还可以使用 QML Profiler 本身来观察我们的改进对绑定评估性能的影响。

我正在使用 Qt Creator 进行此操作，因为这是进行此类改进的方便目标。不过，这里展示的技术可以应用于任何应用程序。我们不会在 QML profiler 上获得令人难以置信的性能提升，因为 QML profiler 的性能受到 I/O 或 C++ 中实现的内部数据转换的限制，具体取决于工作负载。但是，我仍将展示如何直接观察您对 QML 代码所做的任何更改对性能的影响。

首先，让我们设置我们的环境。以下是关于如何构建 Qt Creator 并在其自身上使用 QML 分析器的简短指南。

# 怎么开始

第一步很简单：从您的 Qt 维护工具安装 Qt 和 Qt Quick Compiler Extensions，克隆 Qt Creator [git 仓库](git://code.qt.io/qt-creator/qt-creator.git)，包括其子模块。

您可以签出 master 分支以避免与 Qt 兼容性相关的编译问题，但请注意，我们要做的一些更改已经集成在 master 中。您可以查看较旧的分支，例如 6.0，以查看原始代码。

现在在 Qt Creator 中打开 CMakeLists.txt。为您刚刚安装的 Qt 版本的套件选择一个 release-with-debuginfo 配置。您不应该尝试构建 qml2puppet，因为它需要针对每个新版本的 Qt 进行调整。我们在这里要做的事情不需要它。在 src/tools/CMakeLists.txt 中，删除以下行：

```cmake
add_subdirectory(qml2puppet)
```

现在您需要启用 QML 调试和分析。 Qt Creator 提供的默认应用程序模板自动为调试和 release-with-debuginfo 配置执行此操作，但 Qt Creator 构建系统不是从这样的模板创建的。要启用 QML 调试和分析，请切换到项目模式并将“QML 调试和分析”下拉菜单设置为“启用”。

![](https://www.qt.io/hubfs/projects.png)![](https://www.qt.io/hubfs/qmldebugging.png)

然后构建。这已经输出了一些有用的警告。事实上相当多。例如：

```txt
Warning: TimeMarks.qml:93:32: Unqualified access
                anchors.right: scaleArea.right
```

这正是我们想要的。我们将详细了解它们，但首先让我们测试运行 QML 分析器并保存示例跟踪。这不是我们要与其他跟踪比较的跟踪，而是我们将加载回 QML 分析器以触发我们优化的代码的测试数据。

# 启动分析器并保存跟踪

在 Qt Creator 中选择 Debug 视图，然后在下拉列表中选择“QML Profiler”。

![](https://www.qt.io/hubfs/debug.png)![](https://www.qt.io/hubfs/profiler.png)

按下拉菜单旁边工具栏中的绿色三角形“开始”按钮。这将启动 Qt Creator 的另一个实例，QML Profiler 会记录跟踪。您会注意到“已用”时间开始在工具栏中滴答作响，并且所有视图都显示一个标有“Profiling Application”的标签。关闭 Qt Creator 的额外实例。结果，时间线视图将显示一个相当无聊的轨迹，只有几个事件。

![](https://www.qt.io/hubfs/exampletrace.png)

现在这已经足够了。在时间线视图中单击鼠标右键，然后从下拉菜单中选择“Save QML Trace”。选择跟踪的位置和文件名。我们稍后会加载它。

# 在 QML Profiler 中寻找自己的方式

在很多地方，我们会收到这样的警告：
```txt
Warning: ButtonsBar.qml:41:5: Could not compile function updateLockButton: Functions without type annotations won't be compiled
    function updateLockButton(locked) {
```
ButtonsBar.qml 是 QML 分析器和性能分析器中时间线视图左上角的按钮行。您可以逐步浏览各个事件并使用这些事件缩放视图。当切换“鼠标悬停时查看事件信息”按钮并启用或禁用悬停选择时，会触发它在这里抱怨的功能。让我们看看这需要多长时间。

像以前一样开始分析 Qt Creator，并切换到打开的 Qt Creator 的新实例。打开 QML Profiler，右键单击时间线并“加载 QML Trace”我们的示例跟踪。然后切换左上角的“鼠标悬停时查看事件信息”按钮几次。

![](https://www.qt.io/hubfs/hoverbutton.png)

最后关闭被跟踪的Qt Creator实例，切换回记录跟踪的Qt Creator实例。在那里，您会在时间线中看到更多事件。

![](https://www.qt.io/hubfs/timeline.png)

我们对时间线的最后一部分感兴趣。您可以使用底部的概述滚动时间线。

我们所看到的直接表达了我们之前与应用程序的交互。切换按钮的鼠标单击被记录为输入事件，其中一些会触发级联的绑定和 JavaScript 评估。 （注意：您可以通过拖放时间线视图左侧的标签来重新排序事件类别。）

您可以单击事件以在一个小信息窗口中查看有关它们的信息。如果您这样做，Qt Creator 也会跳转到相关的源代码。在像这样的简单跟踪中，只需检查时间轴中的事件即可轻松找到我们要查找的函数。它是每个输入事件中最底层的 JavaScript 函数。单击它会为您提供有关 updateLockButton() 的特定调用的信息。您可以在 Statistics 视图中看到所有同类事件的聚合，在本例中是对 updateLockButton() 的所有调用。所有视图中的选择都是同步的。因此，只需切换到统计视图即可将您带到正确的行。

![](https://www.qt.io/hubfs/statistics.png)

在我的电脑上，我切换按钮的 8 次累计时间为 61.4µs，每次调用平均需要 7.67µs。当然，这不是一个具有统计意义的测量。然而，出于演示目的，它已经足够好了。

让我们记住这个数字，直到本系列的下一篇文章。现在我们已经刷新了对 QML profiler 的记忆，我们可以继续更改代码并观察以这种方式实现的效果。在下一篇文章中，我将展示在没有类型注释的情况下如何处理这些函数。