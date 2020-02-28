---
title: "Jekyll插入PlantUML代码显示图片"
tags: ["Jekyll", "PlantUML"]
categories: ["Blog"]
image: https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-02-28/plantuml.jpg
layout: post
author: missdeer
featured: false
---
突然心血来潮，花了点时间写了个Jekyll的插件，用于生成PlantUML的各种图。用法大体是这样的：

1. 下载编译一个[Go程序](https://github.com/missdeer/plantuml-cmd)，这个程序用于完成将PlantUML代码转换为图片的任务，支持远程http(s)调用和本地jar调用两种方式：
```bash
go get github.com/missdeer/plantuml-cmd
```
2. 把生成的可执行文件拷贝到某个合适的路径，比如
```bash
cp $GOPATH/bin/plantuml-cmd /usr/local/bin/
```
3. 将`https://github.com/missdeer/plantuml-cmd`这个仓库中的所有`.rb`文件保存到Jekyll项目的`_plugins`目录
4. 修改Jekyll项目的`_config.yml`文件，加几行：
```yaml
plantuml:
  remote: "enabled"
  plantuml_cmd: /usr/local/bin/plantuml-cmd   
  tmp_folder: _plantuml
```
5. 然后就可以在文章直接书写PlantUML代码了，Jekyll运行时会调用插件将PlantUML代码转为图片并插入HTML中，除了Ditaa类型是插入外部PNG作为img tag外，其他类型都是直接插入SVG代码到HTML中。
6. 大功告成！各种类型如何使用见下方示例。

## PlantUML示例

##### 代码
```txt
{{ "{% plantuml " }}%}
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: another authentication Response
{{ "{% endplantuml " }}%}
```

##### 输出显示
{% plantuml %}
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: another authentication Response
{% endplantuml %}

## Ditaa示例

##### 代码
```txt
{{ "{% ditaa " }}%}
+--------+   +-------+    +-------+
|        +---+ ditaa +--> |       |
|  Text  |   +-------+    |diagram|
|Document|   |!magic!|    |       |
|     {d}|   |       |    |       |
+---+----+   +-------+    +-------+
	:                         ^
	|       Lots of work      |
	+-------------------------+
{{ "{% endditaa " }}%}
```

##### 输出显示
{% ditaa %}
+--------+   +-------+    +-------+
|        +---+ ditaa +--> |       |
|  Text  |   +-------+    |diagram|
|Document|   |!magic!|    |       |
|     {d}|   |       |    |       |
+---+----+   +-------+    +-------+
	:                         ^
	|       Lots of work      |
	+-------------------------+
{% endditaa %}

## Graphviz dot示例

##### 代码
```txt
{{ "{% dot " }}%}
digraph foo {
  node [style=rounded]
  node1 [shape=box]
  node2 [fillcolor=yellow, style="rounded,filled", shape=diamond]
  node3 [shape=record, label="{ a | b | c }"]

  node1 -> node2 -> node3
}
{{ "{% enddot " }}%}
```

##### 输出显示
{% dot %}
digraph foo {
  node [style=rounded]
  node1 [shape=box]
  node2 [fillcolor=yellow, style="rounded,filled", shape=diamond]
  node3 [shape=record, label="{ a | b | c }"]

  node1 -> node2 -> node3
}
{% enddot %}

## 思维导图示例

##### 代码
```txt
{{ "{% mindmap " }}%}
+ OS
++ Ubuntu
+++ Linux Mint
+++ Kubuntu
+++ Lubuntu
+++ KDE Neon
++ LMDE
++ SolydXK
++ SteamOS
++ Raspbian
-- Windows 95
-- Windows 98
-- Windows NT
--- Windows 8
--- Windows 10
{{ "{% endmindmap " }}%}
```

##### 输出显示
{% mindmap %}
+ OS
++ Ubuntu
+++ Linux Mint
+++ Kubuntu
+++ Lubuntu
+++ KDE Neon
++ LMDE
++ SolydXK
++ SteamOS
++ Raspbian
-- Windows 95
-- Windows 98
-- Windows NT
--- Windows 8
--- Windows 10
{% endmindmap %}

## 甘特图示例

##### 代码
```txt
{{ "{% gantt " }}%}
[Test prototype] lasts 10 days
[Prototype completed] happens at [Test prototype]'s end
[Setup assembly line] lasts 12 days
[Setup assembly line] starts at [Test prototype]'s end
{{ "{% endgantt " }}%}
```

##### 输出显示
{% gantt %}
[Test prototype] lasts 10 days
[Prototype completed] happens at [Test prototype]'s end
[Setup assembly line] lasts 12 days
[Setup assembly line] starts at [Test prototype]'s end
{% endgantt %}

## Math示例

##### 代码
```txt
{{ "{% math " }}%}
f(t)=(a_0)/2 + sum_(n=1)^ooa_ncos((npit)/L)+sum_(n=1)^oo b_n\ sin((npit)/L)
{{ "{% endmath " }}%}
```

##### 输出显示
{% math %}
f(t)=(a_0)/2 + sum_(n=1)^ooa_ncos((npit)/L)+sum_(n=1)^oo b_n\ sin((npit)/L)
{% endmath %}

## LaTeX示例

##### 代码
```txt
{{ "{% latex " }}%}
\sum_{i=0}^{n-1} (a_i + b_i^2)
{{ "{% endlatex " }}%}
```

##### 输出显示
{% latex %}
\sum_{i=0}^{n-1} (a_i + b_i^2)
{% endlatex %}

想想其实好像没啥用哈，我极少要用到这些，真是浪费时间。