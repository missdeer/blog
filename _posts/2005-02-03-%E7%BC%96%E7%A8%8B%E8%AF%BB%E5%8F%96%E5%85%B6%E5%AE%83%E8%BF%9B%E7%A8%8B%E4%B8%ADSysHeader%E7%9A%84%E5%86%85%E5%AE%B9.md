---
layout: post
image: https://img.peapix.com/63efec8ceb984cc1bcdcec348d912e5d_320.jpg
author: missdeer
title: 编程读取其它进程中SysHeader的内容
categories: 
 - imported from CSDN
description: 编程读取其它进程中SysHeader的内容
tags: 
---

```cpp
void __fastcall TMainForm::GetHeaderContent()
{
        //TODO: Add your source code here
    int nItemCount;
    int i;
    char chBuffer[256];
    DWORD dwProcessID;
    HANDLE hProcess;
    void * Pointer;
    SIZE_T nNumberOfBytesRead;
    HD_ITEM Item;
   
    nItemCount = Header_GetItemCount(hWindow);
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
       Item.mask = HDI_TEXT;
       Item.pszText = (LPSTR)((UINT *)Pointer + sizeof(HD_ITEM));
       Item.cchTextMax = sizeof(chBuffer);

       WriteProcessMemory(hProcess,
                        Pointer,
                        &Item,
                        sizeof(HD_ITEM),
                        &nNumberOfBytesRead);
       Header_GetItem (hWindow, i, (LPARAM)Pointer);
       ReadProcessMemory(hProcess,
                    ((UINT *)Pointer + sizeof(HD_ITEM)),
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