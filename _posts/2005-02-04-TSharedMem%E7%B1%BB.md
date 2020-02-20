---
layout: post
image: https://img.peapix.com/17878228342876509293_320.jpg
author: missdeer
title: TSharedMem类
categories: 
 - imported from CSDN
description: TSharedMem类
tags: 
---

```cpp
/// SharedMem.h

class TSharedMem
{
private:
   bool FCreated;
   BYTE *FFileView;
   HANDLE FHandle;
public:
   TSharedMem(const TCHAR* Name, int Size);
   ~TSharedMem();

   bool IsUnique();
   BYTE *Buffer();
};

/// end of SharedMem.h

/// SharedMem.cpp

#include <windows.h>
#include <tchar.h>
#include "sharedmem.h"

TSharedMem::TSharedMem(const TCHAR* Name, int Size)
{
    FHandle = CreateFileMapping((HANDLE)0xFFFFFFFF,
         NULL, PAGE_READWRITE, 0, Size, Name);
    if (FHandle != NULL) {
        FCreated = GetLastError() == 0;
        FFileView = (BYTE*)MapViewOfFile(FHandle,
            FILE_MAP_WRITE, 0, 0, Size);
        if (FFileView && FCreated)
            ZeroMemory(FFileView, Size);
    }
    else
        FFileView = NULL;
}
TSharedMem::~TSharedMem()
{
   if (FFileView) UnmapViewOfFile(FFileView);
   if (FHandle) CloseHandle(FHandle);
}
bool TSharedMem::IsUnique()
{
 return FCreated;
}
BYTE * TSharedMem::Buffer()
{
 return FFileView;
}

///  end of SharedMem.cpp
```

`TSharedMem`类，可以根据构造函数的参数，进行创建或打开相应的内存映射文件。

内存映射文件可用于进程间数据共享。数据共享带来的便利，可从这2个例子中看出。

1、进程间传递数据。这是在一例用远程线程注入DLL进行Edit框字符探测。

```cpp
/// dllmain.cpp

#include <Windows.h>
#include "sharedmem.h"
extern "C" __declspec(dllexport) void GetPassword();
BOOL APIENTRY DllMain( HANDLE hModule,
       DWORD  ul_reason_for_call,
       LPVOID lpReserved
       )
{
 switch(ul_reason_for_call)
 {
 case DLL_PROCESS_ATTACH:
  GetPassword();
  break;
 default:
  break;
 }
 return TRUE;
}
//---------------------------------------------------------------------------
void GetPassword()
{
 
 HWND *phwnd, hwnd;
 TSharedMem sm("LLYFSpy GetPassword", 1024); //实际上会打开这个内存映射文件

 if(sm.IsUnique()==false)
 {
  phwnd = (HWND *)(sm.Buffer());
  hwnd = *phwnd;
  int iLen;
  
  iLen = (int)SendMessage(hwnd, WM_GETTEXTLENGTH, 0,0);
  SendMessage(hwnd, WM_GETTEXT, iLen+1, (LPARAM)sm.Buffer());
  
 }
}
```

上面，导出函数`GetPassword`从共享内存中获知Edit 窗口句柄，然后发送消息探测Edit 窗口中的Text，再将Text 写回共享内存。这个程序可用VC2003 编译生成dll 文件。

下面，是宿主程序将DLL 文件注入被探测进程内，并通过共享内存将被探测Edit 窗口句柄传递过去，程序可在BCB6 中编译：

```cpp
void __fastcall TMainForm::GetEditContent()
{
    char chBuffer[65535];
    DWORD m_dwProcessId;
    AnsiString m_szDllFile;
    int iLen;
   
    if(GetWindowLongPtr(hWindow, GWL_STYLE) & ES_PASSWORD )  
    //只有ES_PASSWORD风格的Edit窗口才要这么麻烦-_-b
    {
        m_szDllFile = ExtractFilePath(Application->ExeName);
        m_szDllFile = m_szDllFile + "\LLYFSpyLib.dll";   //要注入的DLL文件名
        GetWindowThreadProcessId(hWindow, &m_dwProcessId);
        iLen = SendMessage(hWindow, WM_GETTEXTLENGTH, 0,0);
       
        TSharedMem sm("LLYFSpy GetPassword", iLen+1);  //创建内存映射文件
        HWND *phwnd;
        phwnd = (HWND *)sm.Buffer();
        *phwnd = hWindow;     //写入句柄值
       
        LoadLib(m_dwProcessId, WideString(m_szDllFile).c_bstr());  
        // 用CreateRemoteThread注入DLL，细节不是本文重点
        lstrcpyn(chBuffer, (LPCSTR)sm.Buffer(), iLen +1);       
        FreeLib(m_dwProcessId, m_szDllFile.c_str());  
        //将注入的DLL从该进程中卸载，细节不是本文重点
    }
    else
    {
        SendMessage(hWindow, WM_GETTEXT , SendMessage(hWindow,
                              WM_GETTEXTLENGTH,
                              0,0)+1, (LPARAM)chBuffer);
    }
    ContentMemo->Lines->Add(chBuffer);
    CaptionEdit->Text = chBuffer;
}
```

2、创建单一实例进程。这是`TSharedMem`类出现的最原始的动机和目的。只要在`WinMain`开头添加这么几句：

```cpp
int APIENTRY _tWinMain(HINSTANCE hInstance,
   HINSTANCE hPrevInstance,
   LPTSTR    lpCmdLine,
   int       nCmdShow)
{
 // TODO: 在此放置代码。
 TSharedMem SharedMem("application_exists_flag", 20); //字符串要尽量不会和别个程序发生冲突
 if (!SharedMem.IsUnique()) return 0; //判断不是唯一的，就退出
  ................
}
```