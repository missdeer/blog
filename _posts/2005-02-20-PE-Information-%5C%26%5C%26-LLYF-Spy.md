---
layout: post
title: PE Information && LLYF Spy
categories: 
 - imported from CSDN
description: PE Information && LLYF Spy
tags: 
---

昨天在看雪论坛精华中看到一段代码，看一了下，在VC2003 下可以正常编译，并dump 出PE 文件的节信息，导入导出函数表，嘿嘿，正好加到LLYF Spy 和LLYF ProcessHelper 中，只不过那个快速排序的算法好像有点问题，有时候程序会死掉。我还没看出来为什么一定要加这个排序过程。好在程序基本上用的都是C 标准库函数，可以没任何障碍地从VC 移植到BCB 下用。

今天，还修改了LLYF Spy 的Windows 页子窗口显示方法。原来我是图方便省事，写了个`EnumChildWindowsProc` 回调函数，用 `EnumChildWindows` 这个API 来解决问题，但显示出来的和MiniSpy 、MySpy 中的不一样，因为这个API会把全部子窗口都枚举出来，所以没有像它们那样的包含关系的体现。今天发现用`GetWindow` 这个API 进程递归调用，就可以了。

```cpp
void __fastcall TMainForm::GetWindowTree()
{
    TTreeNode *Node;
    char szClassName[256];
    GetClassName(hWindow, szClassName, 256);

    WndTreeView->Items->Clear();
    Node = WndTreeView->Items->Add(NULL,
              AnsiString(szClassName)+" (HWND:0x"+IntToHex((int)hWindow,8)+")");
    this->GenerateWindowsTree(hWindow, Node);
    WndTreeView->FullExpand();
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::GenerateWindowsTree(HWND hwnd, TTreeNode * pnode)
{
    HWND hChild;
    TTreeNode *pSubNode;
    char szClassName[256];
    hChild = GetWindow(hwnd, GW_CHILD);
    while(hChild != NULL)
    {
       GetClassName(hChild, szClassName, 256);
       pSubNode = WndTreeView->Items->AddChild(pnode,
                       AnsiString(szClassName)+" (HWND:0x"+IntToHex((int)hChild,8)+")");
       GenerateWindowsTree(hChild, pSubNode);
       hChild = GetWindow(hChild, GW_HWNDNEXT);
    }
}
//---------------------------------------------------------------------------
```