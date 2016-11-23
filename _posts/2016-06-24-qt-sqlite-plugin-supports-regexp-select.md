---
layout: post
title: "让Qt的sqlite插件支持REGEXP查询"
categories: Coding
description: 让Qt的sqlite插件支持REGEXP查询
tags: Qt sqlite
---
仍然是日志查看程序，突然想要加个按正则表达式的查询，记得sqlite是支持REGEXP的，不过sqlite[官方文档](https://www.sqlite.org/lang_expr.html)上说了，需要程序自己提供一个进行正则匹配的函数，然后调用`sqlite3_create_function`来实现。

在Qt中实现需要以下几步：

1. 获取`sqlite3 *`；
2. 调用`sqlite3_initialize`，这个函数到底什么作用我也不清楚，看文档也没看明白，只说在嵌入式系统上要调，工作站系统上没必要，但这里如果不调用的话，下一步调用`sqlite3_create_function`就会crash，囧；
3. 实现正则表达式匹配函数，供sqlite3回调；
4. 将上一步实现的函数注册到sqlite3中，通过调用`sqlite3_create_function`完成;
5. 编译链接时要提供与Qt使用的相同版本的sqlite3.c和sqlite3.h，因为这里调用了sqlite的C接口函数，而Qt虽然封装了sqlite，却没有暴露这些函数出来，只能自己链接一份了。Qt 5.7用的是3.11.1.0版本，如果版本不一致，则数据库打开后不能close，或者close就crash。

代码如下：

```cpp

static void qtregexp(sqlite3_context* ctx, int /*argc*/, sqlite3_value** argv)
{
    QRegExp regex;
    QString pattern((const char*)sqlite3_value_text(argv[0]));
    QString text((const char*)sqlite3_value_text(argv[1]));

    regex.setPattern(pattern);
    regex.setCaseSensitivity(Qt::CaseInsensitive);

    bool b = text.contains(regex);

    if (b)
    {
        sqlite3_result_int(ctx, 1);
    }
    else
    {
        sqlite3_result_int(ctx, 0);
    }
}

/////////////////////////////////////////////////////////////

    QSqlDatabase db = QSqlDatabase::database(m_dbFile, true);
    if (!db.isValid()) {
        db = QSqlDatabase::addDatabase("QSQLITE", m_dbFile);
        db.setDatabaseName(m_dbFile);
    }

    if (!db.isOpen())
    {
        if (db.open())
        {
            QVariant v = db.driver()->handle();
            if (v.isValid() && qstrcmp(v.typeName(), "sqlite3*")==0)
            {
                sqlite3 *db_handle = *static_cast<sqlite3 **>(v.data());
                if (db_handle != 0)
                {
                    sqlite3_initialize();
                    // must use the same sqlite3 version with the one Qt ships, aka. Qt 5.7 uses sqlite3 3.11.1.0
                    // http://www.sqlite.org/2016/sqlite-amalgamation-3110100.zip
                    sqlite3_create_function_v2(db_handle, "regexp", 2, SQLITE_UTF8 | SQLITE_DETERMINISTIC, NULL, &qtregexp, NULL, NULL, NULL);
                }
            }
        }
    }
```
