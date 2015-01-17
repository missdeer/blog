---
layout: post
title: "Go语言Unmarshal GBK编码的XML"
categories: coding
description: 默认不支持UTF-8以外其他编码的XML文档Unmarshal
tags: Golang GBK XML
---
昨天在写微信公众号文章的爬虫，中间需要解析一段GBK编码的XML，结果发现Go语言自带的encoding/xml包默认是不支持除UTF-8以外其他编码的。在网上随便搜了搜，能看到代码的方法不是过时的就是不能work的，最后还是看到比较官方的一个包可以解决这个问题，代码如下：

```go
import "code.google.com/p/go.net/html/charset"
 
ad := &models.ArticleDocument{}
d := xml.NewDecoder(bytes.NewReader([]byte(xmldoc)))
d.CharsetReader = func(s string, r io.Reader) (io.Reader, error) {
        return charset.NewReader(r, s)
    }
d.Decode(ad)
```
