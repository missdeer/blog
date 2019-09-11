---
layout: post
author: missdeer
title: "C++11 lambda表达式tips"
categories: CPPOOPGPXP 
description: "一些C++11 lambda表达式使用注意事项"
tags: "C++11"
---

C++11加入的lambda表达式是一大进步，大概这样用：

```c++
int a = 1;
auto f = [&a](int n)->int {
    return n+a;
};
int b = f(2);
```

这段代码定义了一个lambda表达式，接受一个`int`变量参数，返回一个`int`值，同时又要捕获（即在lambda表达式内访问）外部变量`a`的引用。

这里有一些tips：

1. 捕获内建类型变量，即不是class/struct的实例的，如果没有修改的需求，传值比传引用要效率少，一般少1条汇编指令。像上面代码中的`&a`，不如改成`a`。

2. 捕获变量列表可以指定多个变量，以逗号分隔，如果有很多变量都要被捕获，方便起见不如直接写一个`[&]`或`[=]`，即全部捕获变量引用或全部捕获变量值，实际上编译器生成代码时，只会对lambda表达式中实际使用到的捕获变量生成相应的代码，没用到的都不会有任何冗余代码开销。

3. 捕获变量如果以值传递，是只读的，在lambda表达式中不能修改，否则编译就会失败。

4. 要注意捕获变量的生命周期，比如在一个范围内将lambda表达式作为回调体（callback entity）延迟调用，如果该lambda表达式的捕获变量已经被销毁（栈上分配的变量出了范围就自动销毁）再调用lambda表达式，则程序可能就crash了。

5. lambda表达式虽然可以在函数体内定义，但实际上基本是个编译期行为，编译器会根据需要将lambda表达式作为一个独立的函数生成代码，比如以下代码:

   ```c++
   class C {
       public:
       void lambdaTest() {
           int a = 1;
           auto f = [&a](int n)->int {
               return n+a;
           };
           int b = f(2);
       }
   };

   void f() {
       C c;
       c.lambdaTest();
   }
   ```

   在gcc 7.1的实现中，会分别生成`C::lambdaTest()`和`C::lambdaTest()::{lambda(int)#1}::operator()(int) const`两个函数的代码，除此之外clang/LLVM，Micrsoft Visual C++和Intel C++基本都是相同的做法。所以一般说来，逻辑上把lambda当成一个普通函数对待即可。但是从编程实践的角度讲，lambda表达式最好不要写太长，越短小越好，不然直接写个独立的函数代码结构会更好。