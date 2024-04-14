---
image: https://blogassets.ismisv.com/media/2024-04-14/system-upgrades.jpg
layout: post
author: missdeer
featured: false
title: "更新FreeBSD、NetBSD、OpenBSD、DragonflyBSD"
categories: os
description: 更新几大BSD的系统和软件包
tags: BSD FreeBSD NetBSD OpenBSD DragonflyBSD
---

之前在PVE上装了几个BSD系统后，也没怎么用，就时不时更新一下，各个BSD有各自的更新方式，这里简单记一下。

更新都是在root下进行，或在命令前加`sudo`。系统更新尽量在控制台进行，不要通过`ssh`远程登录执行，因为`ssh`进程很可能会在更新过程中被干掉。

# FreeBSD

## 更新系统

### 更新补丁

```bash
freebsd-update fetch install
```

### 更新大版本

```bash
freebsd-update -r 14.0-RELEASE upgrade
freebsd-update install
reboot
freebsd-update install
pkg-static install -f pkg
pkg update
pkg upgrade
/usr/sbin/freebsd-update install
reboot
```

## 更新预编译包

```bash
pkg update && pkg upgrade
```

## 修改包镜像源

修改文件`/usr/local/etc/pkg/repos/FreeBSD.conf`。

# NetBSD

## 更新系统

```
sysupgrade auto ftp://ftp.netbsd.org/pub/NetBSD/NetBSD-10.0/amd64
```

## 更新预编译包

```bash
pkgin update && pkgin upgrade
```

## 修改包镜像源

修改文件`/usr/pkg/etc/pkgin/repositories.conf`。

# OpenBSD

## 更新系统

```bash
sysupgrade auto https://ftp.usa.openbsd.org/pub/OpenBSD/7.5/amd64
```

## 更新预编译包

```bash
pkg_add -iuv
```

## 修改包镜像源

修改文件`/etc/installurl`。

# DragonflyBSD

## 更新系统

看[官方文档](https://www.dragonflybsd.org/docs/handbook/Upgrading/)，需要自己下载源代码，编译，安装，再重启。

## 更新预编译包

```bash
pkg update && pkg upgrade
```

## 修改包镜像源

修改文件`/usr/local/etc/pkg/repos/df-latest.conf`。