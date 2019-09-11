---
layout: post
author: missdeer
title: "Go语言用表驱动替换if-else/switch-case/select-case"
categories: Go
description: Go语言用表驱动替换if-else/switch-case/select-case
tags: avege Go
---

没心情给[avege](https://github.com/avege/avege)做新功能，就断断续续做些重构工作，用[gocyclo](https://github.com/fzipp/gocyclo)看出来很多函数的圈复杂度都很高，常规的做法，除了把一个大函数拆成几个小函数外，还要对代码逻辑进行调整，比较可观的做法是把`if-else`，`switch-case`和`select-case`替换掉。

Go对C的`switch-case`结构做了扩展，`switch`后的表达式值除了可以是整形外，还可以是字符串，`case`后可以同时接几个常量值，这使得我这样有多年C/C++使用经历的人一下子很喜欢用`switch-case`:

```go
switch inbound {
  case "socks", "socks5":
  ...
  case "tunnel":
  ...
  case "redir":
  ...
}
```

这么一段代码就有4个分支，圈复杂度就会增加4，如果省略号处的代码稍微冗长一点，放几个`if-else`结构，圈复杂度还会更高。

重构这块代码分两步：

1. 提取`case`处理逻辑到独立的函数中：

   ```go
   switch inbound {
     case "socks", "socks5":
       onSocks()
     case "tunnel":
     	onTunnel()
     case "redir":
     	onRedir()
   }
   func onSocks() {...}
   func onTunnel() {...}
   func onRedir() {...}
   ```

2. 用map替换`switch-case`：

   ```go
   inboundHandlers := map[string]func() {
     "socks": onSocks,
     "socks5": onSocks,
     "tunnel": onTunnel,
     "redir": onRedir,
   }
   if handler, ok := inboundHandlers[inbound]; ok {
     handler()
   }
   func onSocks() {...}
   func onTunnel() {...}
   func onRedir() {...}
   ```

如此圈复杂度就降到1了。

----

上面的handler非常简单，没有参数，没有返回值。可以稍微复杂一点，比如有一批字符串，现在需要判断它们是否匹配某种pattern，这些pattern可能是检测是否匹配一个正则表达式，可能是检测是否以某个子字符串结尾，也可能是检测是否与另一个字符串完全相同等等。我可能会写出这样的代码：

```go
for _, s := range stringArray {
  if regexpMatched(s, pattern) {
    ...
  }
  if equalTo(s, pattern) {
    ...
  }
  if strings.HasSuffix(s, pattern) {
    ...
  }
  ...
}
```

这样有几种pattern，就会有几个`if`分支。而且，同样的匹配算法，可能因为pattern值不同，需要分别用一个`if`分支去处理，代码则会变得更冗长。得益于Go把函数作为first class value，可以通过closure来重构这块代码：

```go
type checker func(string)bool
func regex(pattern string) checker {
  r := regexp.MustCompile(pattern)
  return func(s string)bool {
    retrun r.MatchString(s)
  }
}
func suffix(pattern string) checker {...}
func prefix(pattern string) checker {...}
func contains(pattern string) checker {...}
func equal(pattern string) checker {...}
checkers := []checker{
  regex(`\d+\w+`),
  regex(`\w+\d+`),
  suffix(`end with me`),
  prefix(`start with me`),
  contains(`including me`),
  equal(`equal to me`),
}

for _, s := range stringArray {
  for _, c := range checkers {
    if c(s) {
      ....
    }
  }
}
```

如此实现代码就变量整洁很多，只多了一个`for`循环，一次`if`分支便能检测所有patterns。如果有了新的检测条件，只要在`checkers`中新加一条规则即可。如果有新的算法，只要新加一个closure即可。而且像`regex`函数的实现，每个正则表达式也只需要在最开始被编译一次即可。

----

Go的一大精髓是channel，同时引入`select`关键字来简化操作，比如在Go中使用定时器，就需要使用到这种机制：

```go
secondTicker := time.NewTicker(1 * time.Second)
minuteTicker := time.NewTicker(1 * time.Minute)
hourTicker := time.NewTicker(1 * time.Hour)
dayTicker := time.NewTicker(24 * time.Hour)
weekTicker := time.NewTicker(7 * 24 * time.Hour)
for doQuit := false; !doQuit; {
	select {
	case <-secondTicker.C:
		onSecondTimer()
	case <-minuteTicker.C:
		onMinuteTimer()
	case <-hourTicker.C:
		onHourTimer()
	case <-dayTicker.C:
		onDayTimer()
	case <-weekTicker.C:
		onWeekTimer()
	case <-quit:
		onQuit()
	}
}
```

这段代码为不同时长分别创建了一个定时器，然后用`select`检测定时器触发的channel，于是就有了这一堆的`case`。

Go在标准库[reflect](https://golang.org/pkg/reflect/)包中提供了一个[Select](https://golang.org/pkg/reflect/#Select)函数用于同时监听多个channels，但是这个设施稍微简陋了点，于是可以这么实现：

```go
type onTicker func()
onTickers := []struct {
	*time.Ticker
	onTicker
}{
	{time.NewTicker(1 * time.Second), onSecondTicker},
	{time.NewTicker(1 * time.Minute), onMinuteTicker},
	{time.NewTicker(1 * time.Hour), onHourTicker},
	{time.NewTicker(24 * time.Hour), onDayTicker},
	{time.NewTicker(7 * 24 * time.Hour), onWeekTicker},
}

cases := make([]reflect.SelectCase, len(onTickers)+1)
for i, v := range onTickers {
	cases[i].Dir = reflect.SelectRecv
	cases[i].Chan = reflect.ValueOf(v.Ticker.C)
}
cases[len(onTickers)].Dir = reflect.SelectRecv
cases[len(onTickers)].Chan = reflect.ValueOf(quit)

for chosen, _, _ := reflect.Select(cases); chosen < len(onTickers); chosen, _, _ = reflect.Select(cases) {
	onTickers[chosen].onTicker()
}

for _, v := range onTickers {
	v.Ticker.Stop()
}
```

也就是说[Select](https://golang.org/pkg/reflect/#Select)函数只接受一个`[]reflect.SelectCase`，有了事件也只返回那个channel在`[]reflect.SelectCase`中的索引号，于是我这里就另外创建了一个跟`[]reflect.SelectCase`对应的辅助slice `onTickers`用于存放相应的信息。

这个实现看起来代码似乎反而变复杂了，但优势是以后如果有新的channel要加进来，或要删掉一个已有的channel，只需要修改`onTickers`初始化的部分就行了。

毕竟以前接受的面向对象的教育是**尽量少地对已有代码作改动**嘛。