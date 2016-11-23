---
layout: post
title: "Go在CJK编码和UTF-8间转换"
categories: coding 
description: 纯Go实现在CJK和UTF-8间进行编码转换 
tags: Go CJK UTF-8 
---
之前也折腾过，但是没完美解决，最近在爬些数据，然后想保存成统一的编码，于是自然而然地有编码转换的问题，在网上找最多的解决方案是通过CGO调用iconv实现，这个方案在mac或Linux之类的系统上很好解决，因为基本上都会有iconv的链接库，即使没有，一条命令就装上了，但在Windows上就麻烦些，首先Windows上用CGO就要稍微麻烦点，需要首先装一个gcc编译器，比如MinGW或其衍生品。我的系统上有个msys2，上面也有iconv的链接库，直接从网上go get一个iconv的go封装package就会通过CGO试图寻找那些归档文件，但它会说找不到mingwex和mingw32的归档文件，这个问题可以通过在CGO_LDFLAGS环境变量中设置链接器搜索路径解决。

虽然这样可以在Windows上也编译生成链接了iconv的程序，但实际上我跑不起来这个程序，双击或直接在console中敲命令行都没有任何反应，也不报错，完全无法定位，于是我只好再想找一个纯Go实现的解决方案，[还真有](http://mengqi.info/html/2015/201507071345-using-Go-to-convert-text-between-gbk-and-utf-8.html)！

Go team提供了CJK几种常见编码的encoder和decoder，所以这很方便了：

```go

import (
	"bytes"
	"errors"
	"io/ioutil"
	"strings"

	"Go.org/x/text/encoding/japanese"
	"Go.org/x/text/encoding/korean"
	"Go.org/x/text/encoding/simplifiedchinese"
	"Go.org/x/text/encoding/traditionalchinese"
	"Go.org/x/text/transform"
)

// ToUTF8 convert from CJK encoding to UTF-8
func ToUTF8(from string, s []byte) ([]byte, error) {
	var reader *transform.Reader
	switch strings.ToLower(from) {
	case "gbk", "cp936", "windows-936":
		reader = transform.NewReader(bytes.NewReader(s), simplifiedchinese.GBK.NewDecoder())
	case "gb18030":
		reader = transform.NewReader(bytes.NewReader(s), simplifiedchinese.GB18030.NewDecoder())
	case "gb2312":
		reader = transform.NewReader(bytes.NewReader(s), simplifiedchinese.HZGB2312.NewDecoder())
	case "big5", "big-5", "cp950":
		reader = transform.NewReader(bytes.NewReader(s), traditionalchinese.Big5.NewDecoder())
	case "euc-kr", "euckr", "cp949":
		reader = transform.NewReader(bytes.NewReader(s), korean.EUCKR.NewDecoder())
	case "euc-jp", "eucjp":
		reader = transform.NewReader(bytes.NewReader(s), japanese.EUCJP.NewDecoder())
	case "shift-jis":
		reader = transform.NewReader(bytes.NewReader(s), japanese.ShiftJIS.NewDecoder())
	case "iso-2022-jp", "cp932", "windows-31j":
		reader = transform.NewReader(bytes.NewReader(s), japanese.ISO2022JP.NewDecoder())
	default:
		return s, errors.New("Unsupported encoding " + from)
	}
	d, e := ioutil.ReadAll(reader)
	if e != nil {
		return nil, e
	}
	return d, nil
}

// FromUTF8 convert from UTF-8 encoding to CJK encoding
func FromUTF8(to string, s []byte) ([]byte, error) {
	var reader *transform.Reader
	switch strings.ToLower(to) {
	case "gbk", "cp936", "windows-936":
		reader = transform.NewReader(bytes.NewReader(s), simplifiedchinese.GBK.NewEncoder())
	case "gb18030":
		reader = transform.NewReader(bytes.NewReader(s), simplifiedchinese.GB18030.NewEncoder())
	case "gb2312":
		reader = transform.NewReader(bytes.NewReader(s), simplifiedchinese.HZGB2312.NewEncoder())
	case "big5", "big-5", "cp950":
		reader = transform.NewReader(bytes.NewReader(s), traditionalchinese.Big5.NewEncoder())
	case "euc-kr", "euckr", "cp949":
		reader = transform.NewReader(bytes.NewReader(s), korean.EUCKR.NewEncoder())
	case "euc-jp", "eucjp":
		reader = transform.NewReader(bytes.NewReader(s), japanese.EUCJP.NewEncoder())
	case "shift-jis":
		reader = transform.NewReader(bytes.NewReader(s), japanese.ShiftJIS.NewEncoder())
	case "iso-2022-jp", "cp932", "windows-31j":
		reader = transform.NewReader(bytes.NewReader(s), japanese.ISO2022JP.NewEncoder())
	default:
		return s, errors.New("Unsupported encoding " + to)
	}
	d, e := ioutil.ReadAll(reader)
	if e != nil {
		return nil, e
	}
	return d, nil
}
```
