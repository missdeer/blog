---
layout: post
author: missdeer
title: 使用OutputDebugString 调试窗口程序
categories: 
 - imported from CSDN
description: 使用OutputDebugString 调试窗口程序
tags: 
---

学编程是从DOS下开始的，用了一定时间的TC2.0，使得养成了用printf 输出变量值进行调试的坏习惯。到了写窗口程序时，就遇到了些麻烦。
窗口程序没有方便的进行控制台输出的方法（其实是我不知道），于是，用了几年的用MessageBox 进行输出的调试手段，太麻烦了，因为MessageBox 会打断程序流程，还要人为手动让它继续运行，这是最让人恼火的。

后来用上了VC.NET2003，发现有OutputDebugString这个调试API，在IDE下调试，则会把它的输出定向到IDE 中的Debugger 上。

再后来发现了DebugTrack，它可以截获OutputDebugString 的输出，而不用开其它笨重的debugger。

于是，照着它的参考文档，自己写了个截获OutputDebugString 输出的程序LLYF DebugCapture。

DebugCapture 完全按照[这份文档](http://www.unixwiz.net/techtips/outputdebugstring.html)中的方法来捕捉调试输出：

先建立一个新线程，在线程中循环：

```cpp
void __fastcall TCaptureDBString::Execute()
{
    /****************************************************************************
     * 1. Create the shared memory segment and the two events. 
          If we can't, exit.
     * 2. Set the DBWIN_BUFFER_READY event so the applications 
          know that the buffer is available.
     * 3. Wait for the DBWIN_DATA_READY event to be signaled.
     * 4. Extract the process ID NUL-terminated string from the 
          memory buffer.
     * 5. Go to step #2
     *****************************************************************************/
        TSharedMem sm("DBWIN_BUFFER", sizeof(struct dbwin_buffer));
        TListItem *Item;
        char szFileName[MAX_PATH];
        hBufReadyEvent = CreateEvent(
                                  NULL,         // no security attributes
                                  FALSE,         // auto-reset event
                                  FALSE,         // initial state is nonsignaled
                                  "DBWIN_BUFFER_READY"  // object name
                                  );

        if (hBufReadyEvent == NULL)
        {
            MessageBox(GetActiveWindow(),
                       "Cannot create event of DBWIN_BUFFER_READY",
                       NULL,
                       MB_OK);
            return;
        }

        hDataReadyEvent = CreateEvent(
                                      NULL,    // no security attributes
                                      FALSE,   // auto-reset event
                                      FALSE,   // initial state is nonsignaled
                                      "DBWIN_DATA_READY"  // object name
                                      );

        if (hBufReadyEvent == NULL)
        {
            MessageBox(GetActiveWindow(),
                       "Cannot create event of DBWIN_DATA_READY",
                       NULL,
                       MB_OK);
            return;
        }

        while(1)
        {
           ::SetEvent(hBufReadyEvent);
           ::WaitForSingleObject(hDataReadyEvent, INFINITE);
           if(Terminated)       //Thread terminated flag
           {
               ::SetEvent(hBufReadyEvent);
               CloseHandle(hBufReadyEvent);
               CloseHandle(hDataReadyEvent);
               return;
           }
           DebugString = *((struct dbwin_buffer*)(sm.Buffer()));
           EnterCriticalSection(&CriticalSection);
  
  //display the result string
  //including PID,Output string, Process Path
           Item = MainForm->DebugListView->Items->Add();
           Item->Caption = IntToStr(MainForm->DebugListView->Items->Count);
           Item->SubItems->Add(IntToStr(DebugString.dwProcessId));
           Item->SubItems->Add(DebugString.data);
           Item->SubItems->Add(GetProcessPath(DebugString.dwProcessId, 
                                              szFileName));
           ListView_EnsureVisible(MainForm->DebugListView->Handle,
                                  MainForm->DebugListView->Items->Count-1,
                                  false);

           LeaveCriticalSection(&CriticalSection);
        }
}
```

其中用于内存映射进行数据传递的结构如下：

```cpp
struct dbwin_buffer {
        DWORD   dwProcessId;
        char    data[4096-sizeof(DWORD)];
};
```

这样，我也可以不用借助其它debugger 进行像DOS 下的调试了。

如果要更像printf 一点，还可以对OutputDebugString 加上一个Wrapper：

```cpp
#include <stdio.h>
#include <stdarg.h>
/*************************************************
 * Example usage(Just like C library function **printf**):
 *     ......
 *     OutputDebugPrintf("Error: %d.", GetLastError());
 *     ......
 *************************************************/
void OutputDebugPrintf(LPCTSTR ptzFormat, ...)
{
 va_list vlArgs;
 TCHAR tzText[1024];
 va_start(vlArgs, ptzFormat);
 wvsprintf(tzText, ptzFormat, vlArgs);
 OutputDebugString(tzText);
 va_end(vlArgs);
}
```

调用OutputDebugPrintf 就可以像printf 进行格式化输出了，哈哈。
