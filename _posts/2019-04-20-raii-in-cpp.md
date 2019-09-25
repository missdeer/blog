---
layout: post
author: missdeer
title: "C++中RAII的实现手法"
categories: CPPOOPGPXP
description: C++11以后RAII的一种实现手法
tags: C++11 Boost
---

[Go](https://golang.org/)语言中有[defer](https://golang.org/ref/spec#Defer_statements)可以在退出当前作用域时执行一个函数调用，C++中以前常用的做法是创建一个类的对象，在该类的析构函数中写入需要执行的代码。而这个对象可以创建在栈中，也可以放在`std::auto_prt<>`或`std::unique_prt<>`之类的地方，只要退出作用域就会被销毁就可以。这在网上能找到不少的讨论，比如C++之父的[这段](http://www.stroustrup.com/bs_faq2.html#finally)，C++ Core Guidelines中的[这段](https://github.com/isocpp/CppCoreGuidelines/blob/master/CppCoreGuidelines.md#e6-use-raii-to-prevent-leaks)，以及Cpp Reference中的[这篇](https://en.cppreference.com/w/cpp/language/raii)。

Boost中也提供了[BOOST_SCOPE_EXIT宏](https://www.boost.org/doc/libs/release/libs/scope_exit/doc/html/BOOST_SCOPE_EXIT.html)，但是用起来相当丑陋，而且像稍早版本的Qt Creator内置的简单的C++语法解析器甚至不能正常解析：

```cpp
{ // Some local scope.
    ...
    BOOST_SCOPE_EXIT(capture_list) {
        ... // Body code.
    } BOOST_SCOPE_EXIT_END
    ...
}
```

到了C++11，这个宏有了[改进](https://www.boost.org/doc/libs/release/libs/scope_exit/doc/html/scope_exit/tutorial.html#scope_exit.tutorial.capturing_all_variables__c__11_only_)，使用lambda的机制：

```cpp
void world::add_person(person const& a_person) {
    persons_.push_back(a_person);

    // This block must be no-throw.
    person& p = persons_.back();
    person::evolution_t checkpoint = p.evolution;
    // Capture all by reference `&`, but `checkpoint` and `this` (C++11 only).
    BOOST_SCOPE_EXIT_ALL(&, checkpoint, this) { // Use `this` (not `this_`).
        if(checkpoint == p.evolution) this->persons_.pop_back();
    }; // Use `;` (not `SCOPE_EXIT_END`).

    // ...

    checkpoint = ++p.evolution;

    // Assign new identifier to the person.
    person::id_t const prev_id = p.id;
    p.id = next_id_++;
    // Capture all by value `=`, but `p` (C++11 only).
    BOOST_SCOPE_EXIT_ALL(=, &p) {
        if(checkpoint == p.evolution) {
            this->next_id_ = p.id;
            p.id = prev_id;
        }
    };

    // ...

    checkpoint = ++p.evolution;
}
```

既然这样，其实我们自己也不是一定要用Boost的实现，可以自己简单实现一个：

```cpp
#include <functional>

class ScopedGuard
{
    std::function<void(void)> m_f;
public:
    ScopedGuard() = delete;
    ScopedGuard(ScopedGuard&&) =delete;
    ScopedGuard(const ScopedGuard&) =delete;
    ScopedGuard& operator=(ScopedGuard&&)=delete;
    ScopedGuard& operator=(const ScopedGuard&)=delete;
    ScopedGuard(std::function<void(void)> f) : m_f(f) {}
    ~ScopedGuard() { m_f(); }
};
```

 使用示例：

```cpp
ScopedGuard queryMutexUnlock([this](){m_queryMutex.unlock();});

ScopedGuard postFinishedQueryEvent([this, e](){QCoreApplication::postEvent(this, e);});
```

有了lambda就是方便。