---
layout: post
author: missdeer
title: "修复mac上的jekyll"
categories: Software
description: 修复mac上的jekyll
tags: jekyll ruby gem macOS
---

自从给blog换了个theme，一直断断续续在调整一些细节，于是不免要用到`jekyll`，不过前些天手贱给公司的iMac升级所有gems，结果升坏啦，一运行`jekyll serve`就会报错：

```
/Library/Ruby/Site/2.0.0/rubygems/core_ext/kernel_require.rb:55:in `require': cannot load such file -- bundler (LoadError)
	from /Library/Ruby/Site/2.0.0/rubygems/core_ext/kernel_require.rb:55:in `require'
	from /Library/Ruby/Gems/2.0.0/gems/jekyll-3.3.1/lib/jekyll/plugin_manager.rb:34:in `require_from_bundler'
	from /Library/Ruby/Gems/2.0.0/gems/jekyll-3.3.1/exe/jekyll:9:in `<top (required)>'
	from /usr/local/bin/jekyll:22:in `load'
	from /usr/local/bin/jekyll:22:in `<main>'
```

然后在网上找各种解决方案，还改`GEM_HOME`呀，从`brew`装`ruby`新版本呀等等，全都不能解决。今天为了调blog的404页面，往github上直接提交了好多次，真的不爽啊。于是又咬牙网上搜了搜，终于修好了`jekyll`。

首先，安装`bundler`：

```bash
sudo gem install -n /usr/local/bin/ bundler
```

我的环境已经被我搞坏掉了，一定要指定安装目录，不然会报错：

```
ERROR:  While executing gem ... (Errno::EPERM)
    Operation not permitted - /usr/bin/bundle
```

然后，借助`bundle`就能运行起`jekyll`了：

```bash
bundle install
bundle exec jekyll serve
```

到这步，其实`jekyll`已经能用了，但以前我是直接运行`jekyll serve`就可以了，所以我希望能恢复到那种状态，运行命令：

```bash
sudo gem cleanup
bundle update
sudo bundle clean --force
```

这时，再运行`gem list`就发现安装的gems包已经恢复成我最早时的状态了，直接运行`jekyll serve`就能正常工作了。