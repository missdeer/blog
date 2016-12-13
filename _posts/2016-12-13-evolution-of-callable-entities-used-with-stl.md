---
layout: post
title: "供STL使用的可调用体的演进"
categories: CPPOOPGPXP
description: 供给STL使用的可调用体（Callable Entities）的演进
tags: cpp C++11 STL Boost
---

很早的时候，“道祖”Andrei Alexandrescu在“道经”《Modern C++ Design》中就有个简单的小结，列举了C++（当时还是C++98）中的可调用体：

1. C风格的函数
2. C风格的函数指针
3. 函数的引用，本质上和const函数指针类似
4. 仿函数functor，即自定义了operator()的对象，也叫函数对象function object
5. 指向成员函数的指针
6. 构造函数

Andrei把它们列出来的目的是想说，这些东西都可以在其右侧添加一对圆括号()，并在里头放入一组合适的参数，用以执行某个处理动作。正是由于这个特性，就可以丢给STL中的algorithm们使用，很多algorithm需要接受一个可调用体，在迭代容器内元素的时候执行一些处理动作。

## C++的蛮荒年代

STL提供了一些现在已经被C++11标记为过时（deprecated）的函数适配器（function adapter）和一些简单的函数对象，比如：

```cpp
std::find_if(coll.begin(), coll.end(),
            std::bind2nd(std::greater<int>(), 42));
```

这样可以在容器coll中找到第一个大于42的元素。如果是成员函数指针，也得包装一下才能用：

```cpp
class Person {
  public:
  	void print() const;
  	...
};

const std::vector<Person> coll;
...

std::for_each(coll.begin(), coll.end(),
             std::mem_fun_ref(&Person::print))
```

这样会把容器coll中的每一个元素（都是Person类的实例）都调用一遍它们的print()成员函数！而且这个函数后面一定要加const！

如果想把容器内的元素作为参数传到某个成员函数内，就要这么干：

```cpp
class Talk {
  public:
  	void to(const Person& who) const;
  	...
};

Talk talk;

std::for_each(coll.begin(), coll.end(),
             std::bind1st(std:mem_fun(&Talk::to), &talk));
```

总之就是不好看，也不方便！

## C++的神话时代

“道祖”的“道经”让那些牛人们知道了C++的模板还可以这么玩！于是最顶尖的那拨人纷纷证道成神，Boost被搞出来极大地扩展了C++语言的能力和库的用途。

Boost提供了几个与函数（可调用体相关的几个库）：

- Bind
- Function
- Lambda
- Phoenix

极大地丰富了可调用体的玩法，在各种新语言把函数作为“第一类值”（first class value）的刺激下，C++在Boost的帮助下，也往这个方向迈出了一步。

有了Boost.Bind，那些fucntion adapter统统可以丢一边去了：

```cpp
std::find_if(coll.begin(), coll.end(),
            boost::bind(std::greater<int>(), _1, 42));
```

其中`std::modulus<int>()`接受两个参数，而`boost::bind`把`_1`占据的位置留给`std::find_if`塞过来的容器元素了，后面再绑定一个其他的参数，比如这里是常量`2`。

这便是Boost.Bind的玩法，它就是扩展了`std::bind1st`和`std::bind2nd`的用法，它不用因为传入的参数该处的位置不同而换一个名字，它只要把参数位置互换即可：

```cpp
std::find_if(coll.begin(), coll.end(),
            boost::bind(std::greater<int>(), 42, _1));
```

效果相当于把`std::bind2nd`换成了`std::bind1st`。

而所有的可调用体，都可以塞进Boost.Function这种类型里面，只要返回值类型/参数列表相同，可调用体就可以被赋给同一个Boost.Function类型的对象：

```cpp
boost::function<float (int x, int y)> f;

// function object
struct int_div { 
  float operator()(int x, int y) const { return ((float)x)/y; }
  float calc(int x, int y) const { return ((float)x)/y; }
};

f = int_div();

std::cout << f(5, 3) << std::endl;

// free function
float mul_ints(int x, int y) { return ((float)x) * y; }

f = &mul_ints;

std::cout << f(5, 3) << std::endl;

// member function
int_div id;
f = boost::bind(&int_div::calc, &id, _1, _2);

std::cout << f(5, 3) << std::endl;

// compare
assert(f == &X::foo);
assert(&compute_with_X != f);
```

这样一来，只要类型一致，那么各种可调用体被塞入对象`f`就可以以类型`boost::function<float (int x, int y)>`被传来传去了，还能用`==`和`!=`进行比较！这就跟其它语言里把函数作为`第一类值`的用法很相似了。

至于Boost.Lambda则是另一个用途：就地创建一个短小的匿名函数。当然不一定强求短小，只是太长太大的话不好看。

```cpp
list<int> v(10);
std::for_each(v.begin(), v.end(), boost::lambda::_1 = 1);
```

上面这段代码就实现了给`v`这个容器中所有元素赋值为`1`这个动作。然后可以配合Boost.Bind玩高级一点：

```cpp
int foo(int);
std::for_each(v.begin(), v.end(), 
              boost::lambda::_1 = boost::lambda::bind(foo, boost::lambda::_1));
```

这段代码把容器`v`里的每一个元素让函数`foo`嚼一遍，再吐回给`v`。

然后它可以使用一些简单的运算符表达式：

```cpp
using namespace boost::lambda;
std::sort(vp.begin(), vp.end(), *_1 > *_2);
```

还能这样：

```cpp
using namespace boost::lambda;
std::for_each(a.begin(), a.end(), (++_1, std::cout << _1));
```

较新版本的Boost.Lambda还支持一些简单的控制结构：

```cpp
using namespace boost::lambda;
std::for_each(a.begin(), a.end(), 
         if_then(_1 % 2 == 0, std::cout << _1));  
```

它实现了C++中常用的if-else/for/while/do-while/switch这些类似的控制结构。

而Boost.Phoenix则是为C++提供了函数式编程的能力，它可以把C++中很多东西变成一个函数对象，比如一个值：

```cpp
using namespace boost::phoenix;
val(3)
val("Hello, World")
```

它们就是一个函数对象，可以这样用：

```cpp
using namespace boost::phoenix;
std::cout << val(3)() << std::endl;
```

除此之外，引用、指针、实参等等，都可以变成函数对象。之后便是丢给STL的algorithm们使用，看起来会比Boost.Lambda更简洁清爽：

```cpp
// former usage
bool is_odd(int arg1)
{
    return arg1 % 2 == 1;
}
std::find_if(c.begin(), c.end(), &is_odd)；
  
// now
using namespace boost::phoenix;
std::find_if(c.begin(), c.end(), arg1 % 2 == 1)
```

然后它也实现了一套类似的控制结构：

```cpp
using namespace boost::phoenix;
std::for_each(v.begin(), v.end(),
    if_(arg1 > 5)
    [
        std::cout << arg1 << ", "
    ]
);
```

## C++的工业时代

在见识到Boost的强大威力之后，C++标准组的人也得到了很多灵感，在C++11中，不但把Boost.Bind，Boost.Function等库直接移入标准库，还从语言层面实现了一个**lambda**！一个lambda...lambda...mbda...da...

于是代码就可以写得灰常干净清爽了：

```cpp
vector<int> coll = { 1,2,3,4,5,6,7,8,9,10 };
long sum = 0;
std::for_each(coll.begin(), coll.end(),
             [&sum](int elem) {
               sum += elem;
             });
```

不但容器初始化变得灰常方便，而且lambda的定义也灰常简洁！从此C++中的可调用体又多了一种：lambda。虽然从它的演进历史来看，本质上跟函数对象差不多。

另外还包括一个新关键字**auto**！auto...to...

```
auto plus10times2 = [](int i) {
  return (i+10)*2;
};
```

多年C++老码农感觉从刀耕火种的农牧时代突然进入了飞机大炮的新时代啊！真是令人激动地内牛满面！Boost表示自己已经被玩坏了，有木有！有木有！有木有！

可以说，自从C++11之后，C++几乎是脱胎换骨，已经成为一门很现代化的新语言了，对提升开发效率有极大的助力！