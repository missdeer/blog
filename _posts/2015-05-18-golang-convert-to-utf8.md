---
layout: post
image: https://img.peapix.com/3798816788040340034_320.jpg
author: missdeer
title: "Go语言中将其他编码字符转换为UTF-8"
categories: Go
description: Go语言中将其他编码字符转换为UTF-8
tags: Go UTF-8
---
今天要把一段文本从gb2313转换为UTF-8，网上有一些第三方库，比如使用iconv之类来转换，其实有比较官方的方法：

```go
import	"golang.org/x/net/html/charset"

// convert from gb2313 to utf-8
r := bytes.NewReader(content)
d, err := charset.NewReader(r, "gb2312")
content, err = ioutil.ReadAll(d)
```

貌似这个方法只能把其他编码转换为UTF-8编码。
