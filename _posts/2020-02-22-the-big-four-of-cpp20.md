---
image: https://blogassets.ismisv.com/media/2020-02-22/TimelineCpp20BigFourUpdate.png
layout: post
author: missdeer
featured: false
title: "C++20：四巨头"
categories:  CPPOOPGPXP 
description: "C++20：四巨头"
tags: C++20 cpp C++
---
>英文原文：https://www.modernescpp.com/index.php/thebigfour

本文向你展示四巨头：concepts，ranges，coroutines和modules（四个名词目前尚未全都有既信达雅，又得到大部分业内人士认同的中文翻译，继续干脆全部保留英文原文。）。

![C++20四大要点时间线更新](https://blogassets.ismisv.com/media/2020-02-22/TimelineCpp20BigFourUpdate.png)

C++20提供了很多东西。在我给你们四巨头的第一印象前，这是C++20的概览。除了四巨头，还有很多特性影响着语言核心、库、以及C++20的并发能力。

# 编译器对C++20的支持

最简单的了解新特性的方法是上手把玩。这个方法马上引出一个问题：哪个编译器支持了C++20的哪些特性？经常地， [cppreference.com/compiler_support](https://en.cppreference.com/w/cpp/compiler_support)能解答关于语言核心和库的这个问题。

简单说来，最最新的GCC，Clang和EDG编译器对语言核心提供了最好的支持。另外，MSVC和苹果Clang编译器也支持了许多C++20的特性。

![语言核心](https://blogassets.ismisv.com/media/2020-02-22/Core.PNG)

库也是类似的。GCC对库的支持最好，接下来是Clang和MSVC编译器。

![库](https://blogassets.ismisv.com/media/2020-02-22/Library.PNG)

上面的截图只显示了表格开始的部分，但能给你一个不是特别满意的答案。甚至你使用所有最最新的编译器，也有很多特性没被任何编译器支持。

经常地，你能找到把玩新特性的变通方法。两个例子：

* Concepts：GCC支持上一个版本的concepts。
* `std::jthread`：[Github](https://github.com/josuttis/jthread)上有一份Nicolai Josuttis维护的实现草案。

简而言之。情况还不错。稍作修改，就可以尝试许多新功能。如有必要，我会提及这一点小技巧。

但是，现在让我给您鸟瞰这些新功能。当然，我们应该从四巨头开始。

# 四巨头

## Concepts

使用模板进行泛型编程的关键思想是定义可以与各种类型一起使用的函数和类。通常，你用错误的类型实例化模板时，结果常常是几页的错误消息。这个悲伤的故事以concepts结束。Concepts使你能够编写模板要求，这些要求可由编译器检查。你革新了我们思考和编写泛型代码的方式。原因如下：

* 模板要求是接口的一部分。
* 可以基于concepts进行函数的重载或类模板的特化。
* 由于编译器将模板参数的要求与实际模板参数进行比较，因此我们得到了改进的错误消息。

但是，这还不是故事的结局。

* 你可以使用预定义的concepts或定义自己的concepts。
* `auto`和concepts的用法是统一的。您可以使用concepts代替`auto`。
* 如果函数声明使用concepts，它将自动成为函数模板。因此，编写函数模板与编写函数一样容易。

以下代码段向你展示了简单的concept `Integral`的定义和用法：

```cpp
template<typename T>
concept bool Integral(){
    return std::is_integral<T>::value;
}

Integral auto gcd(Integral auto a,     
                  Integral auto b){
    if( b == 0 ) return a; 
    else return gcd(b, a % b);
}
```

`Integral`是一个concepts，要求它具有`std::is_integral<T>::value`的类型参数`T`。`std::is_integral<T>::value`是`type-traits`库中的一个函数，该函数在编译时检查`T`是否为整数。 如果`std::is_integral<T>::value`的值为`true`，则一切正常。如果不是，则会出现编译时错误。对于好奇的人——你应该好奇——这是我写的与`type-traits`库相关的[文章](https://www.modernescpp.com/index.php/tag/type-traits)。

`gcd`算法基于[欧几里得算法](https://en.wikipedia.org/wiki/Euclidean_algorithm)确定最大公约数。我使用了所谓的缩写函数模板语法来定义`gcd`。`gcd`从其参数和返回类型要求它们支持concept `Integral`。`gcd`是一种函数模板，它对参数和返回值提出了要求。 当我删除[语法糖](https://en.wikipedia.org/wiki/Syntactic_sugar)时，也许你可以看到`gcd`的真正本质。

这是语义上等效的`gcd`算法。

```cpp
template<typename T>
requires Integral<T>()
T gcd(T a, T b){
    if( b == 0 ) return a; 
    else return gcd(b, a % b);
}
```

如果您看不到`gcd`的真正本质，则必须等待我几周后发表有关concepts的文章。

## Ranges库

Ranges库是Concepts的第一位客户。它支持的算法将会：

* 能直接操作容器，你不需要用迭代器指定范围 
* 能惰性求值
* 能被组合

简而言之：Ranges库支持函数式模式。

好了，代码更胜于文字。下面的函数通过管道符号展示了函数组合：

```cpp
#include <vector>
#include <ranges>
#include <iostream>
 
int main(){
  std::vector<int> ints{0, 1, 2, 3, 4, 5};
  auto even = [](int i){ return 0 == i % 2; };
  auto square = [](int i) { return i * i; };
 
  for (int i : ints | std::view::filter(even) | 
                      std::view::transform(square)) {
    std::cout << i << ' ';             // 0 4 16
  }
}
```
`even`是一个lambda函数用于判断`i`是否偶数，而且lambda函数`square`将`i`计算成它的平方。剩下的函数组合你要从左往右读：`for (int i : ints | std::view::filter(even) | std::view::transform(square))`。将`ints`的每个元素都应用上过滤器`even`，并将每个出来的值映射到它的平方`square`。如果你熟悉函数式编程，这读起来就像散文。

## Coroutines

Coroutines是广义的函数，可以在保持其状态的同时暂停和恢复它们。Coroutines是编写事件驱动的应用程序的常用方法。事件驱动的应用程序可以是模拟，游戏，服务器，用户界面甚至算法。Coroutines通常也用于[协作多任务](https://en.wikipedia.org/wiki/Cooperative_multitasking)。

我们没有C++20的具体coroutines。我们将获得一个编写自己coroutines的框架。编写coroutines的框架包含20多个函数，你必须部分实现这些功能，而部分可能会重写它们。 因此，你可以根据需要定制coroutines。

让我向你展示特殊coroutines的用法。以下程序是一个用于生成无限数据流的生成器。

```cpp
Generator<int> getNext(int start = 0, int step = 1){
    auto value = start;
    for (int i = 0;; ++i){
        co_yield value;            // 1
        value += step;
    }
}

int main() {
    
    std::cout << std::endl;
  
    std::cout << "getNext():";
    auto gen = getNext();
    for (int i = 0; i <= 10; ++i) {
        gen.next();               // 2
        std::cout << " " << gen.getValue();                  
    }
    
    std::cout << "\n\n";
    
    std::cout << "getNext(100, -10):";
    auto gen2 = getNext(100, -10);
    for (int i = 0; i <= 20; ++i) {
        gen2.next();             // 3
        std::cout << " " << gen2.getValue();
    }
    
    std::cout << std::endl;
    
}
```
好吧，我必须补充几句话。这只是一个代码片段。函数`getNext`是一个coroutine，因为它使用关键字`co_yield`。 `getNext`有一个无限循环，返回`co_yield`之后的值。调用`next()`（第2行和第3行）将恢复coroutine，随后的`getValue`调用将获取该值。在`getNext`调用之后，coroutine再次暂停。它会暂停直到下一个`next()`调用。在我的示例中有一个大的未知数。这个未知数是`getNext`函数的返回值`Generator <int>`。从这里开始，开始进行复杂的工作，这将成为coroutine详细文章的一部分。

感谢[Wandbox](https://wandbox.org/)在线编译器，我可以向您展示程序的输出。

![无限数据流](https://blogassets.ismisv.com/media/2020-02-22/infiniteDataStream.PNG)

## Modules

对于modules，我讲得非常少，因为文章已经太长了。

Modules承诺：

* 更快的编译速度
* 与宏隔离
* 表达出代码的逻辑结构
* 不再需要头文件
* 处理丑陋的宏的变通方法

## 下一步？

在对四巨头有了个高层概览后，我将在下一篇文章中继续介绍语言核心特性。