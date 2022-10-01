---
image: https://blogassets.ismisv.com/media/2021-07-20/cmake+qt.jpg
layout: post
author: missdeer
featured: false
title: "关于Qt/CMake的一个经验"
categories: Qt
description: 关于Qt/CMake的一个经验
tags: Qt CMake
---
不要使用Qt安装器中提供的CMake，而是自己另外安装一份，比如从CMake官网下载，或者macOS上可使用Homebrew在线安装。

也许你一直用Qt安装器中的那个CMake用得好好的，那没关系。如果有一天突然遇到莫名其妙的CMake配置错误，可以试试使用其他安装的版本，哪怕是被qt-cmake调用的情况下。