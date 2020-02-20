---
layout: post
image: https://img.peapix.com/10910981781494828490_320.jpg
author: missdeer
title: 关于OutputDebugString 的模拟
categories: 
 - imported from CSDN
description: 关于OutputDebugString 的模拟
tags: 
---

从[这篇文章](http://www.unixwiz.net/techtips/outputdebugstring.html)中可以知道，通过简单的几步设置，便可模拟OutputDebugString，可以用下面的代码描述：

```cpp
struct dbwin_buffer {
        DWORD   dwProcessId;
        char    data[4096-sizeof(DWORD)];
};

void MyOutputDebugString(LPCTSTR lpOutputString)
{
    static HANDLE hMutex = OpenMutex(MUTEX_ALL_ACCESS,      // request full access
                 FALSE,                 // handle not inheritable
                 "DBWinMutex");
    if(hMutex != NULL)
    {
      TSharedMem SharedMem("DBWIN_BUFFER", sizeof(struct dbwin_buffer));
      if(!SharedMem.IsUnique())
      {
        HANDLE hBufEvent, hDataEvent;
        hBufEvent = OpenEvent(EVENT_ALL_ACCESS, FALSE, "DBWIN_BUFFER_READY");
        if(hBufEvent != NULL)
        {
          hDataEvent = OpenEvent(EVENT_ALL_ACCESS, FALSE, "DBWIN_DATA_READY");
          if(hDataEvent!=NULL)
          {               
            if(WaitForSingleObject(hBufEvent, 10000)==WAIT_OBJECT_0)
            {
              struct dbwin_buffer *buffer = (struct dbwin_buffer *)SharedMem.Buffer();
              DWORD dwPID = GetCurrentProcessId();
              memcpy(buffer, &dwPID, sizeof(DWORD));
              lstrcpyn(buffer->data, lpOutputString, 4096-sizeof(DWORD));
              SetEvent(hDataEvent);
            }                    
            CloseHandle(hDataEvent);
          }                         //if(hDataEvent != NULL)
          CloseHandle(hBufEvent);
        }                        //if(hBufEvent != NULL)
      }                          //if(!SharedMem.IsUnique())
      ReleaseMutex(hMutex);  
    }                         //if(hMutex != NULL)
}
```

但，事实上，我在VS.NET2003 的环境下，并不能向它的debugger 输出任何内容，而且检测到并没有这个内存映射区域，也没有这2个Event，但同时，它仍能很好地拦截系统OutputDebugString 的输出，看来它是通过API Hook 之类的其它手段了。但我没有验证，尽管上面这段代码和OutputDebugString 产生的输出都能很好地被LLYF DebugCapture 这些程序拦截到。
