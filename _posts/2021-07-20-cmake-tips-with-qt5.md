---
image: https://cdn.jsdelivr.net/gh/missdeer/blog@master/media/2021-07-20/cmake+qt.jpg
layout: post
author: missdeer
featured: false
title: "使用cmake构建Qt5程序的一些坑"
categories: 
description: "cmake-tips-with-qt5"
tags: cmake Qt
---
突然想试一下CLion上写Qt5程序是什么体验，反正有JB家的全家桶License。CLion使用cmake作为构建工具，而Qt官方也开始支持cmake，但使用过程中还是遇到一些坑，记录一下。

# 读Qt的cmake使用帮助

这点很重要，一些最重要的问题在使用帮助中已经提到了，一定要逐字逐句读一遍。

## 设置Qt路径

这个在网上随便搜一下就能找到很多文章都提到了，就是设置到`CMAKE_PREFIX_PATH`或`Qt5_DIR`中，注意设置到系统环境变量中与作为命令行参数传给cmake效果是有区别的，我发现作为命令行参数传递比较省事。

## 编译可执行文件或动态库

如果编译的项目是个exe或动态库，需要将Qt模块添加到目标链接库列表中，这样cmake就会自动把Qt的头文件路径和库文件路径添加到编译器的搜索路径列表中：

```cmake
target_link_libraries(MyProgram Qt::Widgets Qt::Network Qt::Xml)
```

## 编译静态库

如果要编译的项目是个静态库，没法用`target_link_libraries`，但光是设置`CMAKE_PREFIX_PATH`仍然会在编译过程中报错找不到Qt的头文件，需要自己加入头文件搜索路径：

```cmake
include_directories(
        ${Qt5Widgets_INCLUDE_DIRS}
        ${Qt5Network_INCLUDE_DIRS}
        ${Qt5Xml_INCLUDE_DIRS}
        )
```
其中`Qt5Widgets_INCLUDE_DIRS`一项就包含了`Widgets`，`Core`和`Gui`三个模块。

## 编译Qt plugin项目

如果要编译的项目是以QtPlugin形式写成的库，要自己定义一个宏`QT_STATICPLUGIN`，这样写就可以：

```cmake
add_compile_definitions(QT_STATICPLUGIN=1)
```

## 生成mac bundle

macOS上的bundle要多打包图标等一些资源，稍微麻烦一点：

```cmake
if (APPLE)
    set(MACOSX_BUNDLE true)
    set(MACOSX_BUNDLE_BUNDLE_NAME MyProgram)
    set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.ismisv.myprogram")
    set(MACOSX_BUNDLE_ICON_FILE "MyProgram.icns")
    set(MACOSX_BUNDLE_INFO_STRING "MyProgram")
    set(MACOSX_BUNDLE_LONG_VERSION_STRING "1.0.0.1")
    set(MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0")
    set(MACOSX_BUNDLE_BUNDLE_VERSION "1.0")

    set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/MyProgram.icns" PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    set_target_properties(
            MyProgram
            PROPERTIES
            RESOURCE "./MyProgram.icns"
            WIN32_EXECUTABLE TRUE
            MACOSX_BUNDLE TRUE
    )
endif()
```

## 指定当前项目使用的编程语言

Cmake可以指定当前项目使用的编程语言，比如：

```cmake
project(MyProgram LANGUAGES CXX)
```

这样cmake只会编译`.cpp`，`.cxx`这些C++编译器认的文件，如果项目中有一些`.c`文件，则会被忽略，所以干脆不写就能编译所有类型的文件：

```cmake
project(MyProgram)
```
