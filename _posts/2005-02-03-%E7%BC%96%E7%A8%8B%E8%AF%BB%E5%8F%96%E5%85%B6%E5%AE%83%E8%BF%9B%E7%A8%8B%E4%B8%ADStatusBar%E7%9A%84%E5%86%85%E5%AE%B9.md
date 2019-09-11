---
layout: post
author: missdeer
title: 编程读取其它进程中StatusBar的内容
categories: 
 - imported from CSDN
description: 编程读取其它进程中StatusBar的内容
tags: 
---

```cpp
void __fastcall TMainForm::GetStatusBarContent()
{
        //TODO: Add your source code here
    int nItemCount;
    int i;
    char chBuffer[256];
    DWORD dwProcessID;
    HANDLE hProcess;
    void * Pointer;
    SIZE_T nNumberOfBytesRead;
   
    nItemCount = SendMessage(hWindow, SB_GETPARTS, 0, 0);
    GetWindowThreadProcessId(hWindow, &dwProcessID);
    hProcess = OpenProcess(PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE,
                    false,
                    dwProcessID);
    Pointer = VirtualAllocEx(hProcess,
                            NULL,
                            4096,
                            MEM_RESERVE | MEM_COMMIT,
                            PAGE_READWRITE);
    try{
    for(i= 0 ; i < nItemCount ; ++i)
    {
       SendMessage(hWindow, SB_GETTEXT, i, (LPARAM)Pointer);
       ReadProcessMemory(hProcess,
                    Pointer,
                    chBuffer,
                    sizeof(chBuffer),
                    &nNumberOfBytesRead);
       ContentMemo->Lines->Add(chBuffer);
    }//for(i...
    }//try
    __finally
    {
      VirtualFreeEx(hProcess,
                    Pointer,
                    0,
                    MEM_RELEASE);
      CloseHandle(hProcess);
    }
}
```