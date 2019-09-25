---
layout: post
image: https://blogimg.minidump.info/2015-04-18-local-mirror-rust-nightly.md
author: missdeer
title: "本地镜像Rust nightly build"
categories: Coding
description: 建立Rust nightly build的本地镜像以加速升级过程
tags: Rust nightly
---
自从Rust版本号跳到1.0，即使离正式发布还有很长一段时间，我就开始打算要学一下Rust，主要还是因为想跟Go比较一下，用Go也一年了，已经能做些比较实用的小项目了，我想看看Rust有哪些方面更优秀，或者说比Go更合适来做某些方面的开发。

虽然还没正式开始学，但兵马未动，粮草先行。我先看看怎么安装Rust，然后看到Rust的快速迭代，可以用命令安装每天的nightly build：

```bash
curl -s https://static.rust-lang.org/rustup.sh | sudo sh -s -- --channel=nightly
```

但是在我大天朝如此奇特的网络环境中，这个命令会有些问题。情况好一点的话，也就是下载速度会很慢，情况差一点就下载压根被重置了，貌似是因为下载的URL中包含了特殊字符串“64”，咳咳。所以建立个镜像来做这个事很有必要。

首先，我有个7*24小时开机的Raspberry Pi当下载机，写个简单的shell脚本加到cron中去每天上午10点定时执行一次，用于下载最新的nightly build包到本地：

```bash
#!/bin/bash
cd /home/pi/rust/dist
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-unknown-linux-gnu.tar.gz
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-unknown-linux-gnu.tar.gz.sha256
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-i686-unknown-linux-gnu.tar.gz
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-i686-unknown-linux-gnu.tar.gz.sha256
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-apple-darwin.pkg
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-apple-darwin.pkg.sha256
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-apple-darwin.tar.gz
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-apple-darwin.tar.gz.asc
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-apple-darwin.tar.gz.sha256
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-pc-windows-gnu.exe
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/rust-nightly-x86_64-pc-windows-gnu.exe.sha256
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/channel-rust-nightly.sha256
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/channel-rust-nightly.asc
curl -O --socks5 127.0.0.1:1080 https://static.rust-lang.org/dist/channel-rust-nightly
```

这里最重要的就是通过socks5代理翻墙了。为什么是每天上午10点，也是稍微有点讲究的，我是假设Raspberry Pi从官网下载速度并不快，但又要下载大约500MB的东西，而每天我本地更新Rust的时间基本上是晚上7点后，所以要留出足够多的时间用于下载，又尽量少的时间空档。

然后把本地目录/home/pi/rust通过http服务器暴露出来，假设是在http://192.168.3.100/rust/，最后把最上面那个更新安装Rust的命令稍微修改一下：

```bash
curl -s --socks5 127.0.0.1:1080 https://static.rust-lang.org/rustup.sh | sed 's/https:\/\/static\.rust\-lang\.org/http:\/\/192.168.3.100\/rust/g' | sed 's/http:\/\/static\-rust\-lang\-org\.s3\-website\-us\-west\-1\.amazonaws\.com/http:\/\/192.168.3.100\/rust/g' | sudo sh -s -- --channel=nightly
```

这样就能以Raspberry Pi的最大输出速率更新Rust到最新的nightly build啦！
