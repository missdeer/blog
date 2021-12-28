---
image: https://upload.wikimedia.org/wikipedia/zh/5/58/DragonFly_BSD_Logo.png
layout: post
author: missdeer
featured: false
title: "把玩BSD"
categories: Coding
description: "把玩BSD，为DragonflyBSD交叉编译应用程序"
tags: DragonflyBSD BSD
---
前些时间脑子发热在淘宝上买了个DeskMini X300，但是出于预算方面的原因，选了个最低档的CPU——AMD 3000G，到手后发现跟Windows10非常慢，有点后悔没有多加千把块钱配个好点的CPU。

我买DeskMini的原因倒不是为了跑Windows，而是为了跑Linux之类的当服务器，然后刚好了解了一下PVE，于是一番折腾，先装了PVE，再陆续装了5个虚拟系统，分别是Debian 11，FreeBSD 13，NetBSD 9.2，OpenBSD 7以及DragonflyBSD 6，而且只装了命令行界面，所有图形界面组件全都没有装，这样一来机器性能就不是什么大问题了。

这些年一直在VPS和HTPC上跑着Debian 11，虽然不是很熟练，但也不陌生。但几个BSD系统，只有好些年前在Thinkpad T43装过一回，也没怎么用，基本属性完全不了解的情况，不过好在安装过程非常简单，连资料都不用看也能基本顺利地完成安装。

安装完成之后，便是设置普通用户，设置服务等等，除了一些Linux上可以使用的命令没有外，日常使用基本上不是特别难的问题，上网仍然能搜到不少资料。不过到目前为止还遗留一个问题：在Linux上建的NFS server，在BSD上挂载后只有只读，但在Linux下可以挂载为读写。

我比较关心的是在各个系统上编写自己的程序是否方便，发现FreeBSD和OpenBSD都默认使用较新版本的clang，NetBSD默认安装某个旧版本gcc，但可以自行用pkgin安装最新的clang。但是DragonflyBSD就比较懒了，默认安装了某个很旧版本的gcc，还没现成的clang安装包。

既没有DragonflyBSD上可用的clang安装包，又不想自己编译一个clang，也不想用老旧的gcc，只能想想在其他平台用clang给DragonflyBSD做交叉编译了。

首先mount好DragonflyBSD的安装镜像ISO，这在Linux和FreeBSD上有一点区别，FreeBSD需要先创建一个回环设备：

```shell
# mdconfig -a -t vnode -f DragonFly-x86_64-LATEST-ISO.iso
```

这时会返回新创建的回环设备名称，比如`md0`，再mount这个设备：

```shell
# mkdir iso
# mount -t cd9660 -o ro /dev/md0 ./iso
```

如果是Linux上则可以直接mount这个iso文件：

```shell
# mkdir iso
# mount -o loop,ro DragonFly-x86_64-LATEST-ISO.iso ./iso
```

写一个经典的`Hello world`，代码如下：

```c
#include <stdio.h>

int main(int argc, char **argv) {
  printf("Hello World\n");
  return 0;
}
```

然后就可以用clang编译了：

```shell
# clang -I./iso/usr/include \
      -L./iso/usr/lib -L./iso/usr/lib/gcc47 \
      -B./iso/usr/lib -B./iso/usr/lib/gcc47 \
      -target x86_64-pc-dragonfly-elf \
      -o helloworld helloworld.c 
```

如果没问题的话，这时应该生成了一个可执行文件`helloworld`，可以用`file`命令看一下文件类型：

```shell
# file helloworld
/home/missdeer/helloworld: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, interpreter /usr/libexec/ld-elf.so.2, for DragonFly 6.0.0, not stripped
```

大体过程就是这样了。但是最好还是编译一套原生的clang吧。