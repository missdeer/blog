---
image: https://blogassets.ismisv.com/media/2024-06-16/debugger.png
layout: post
author: missdeer
featured: false
title: "Windows平台使调试器在子进程启动时attach"
categories: Coding
description: Windows平台使调试器在子进程启动时attach
tags: Windows coding debugging
---

因为程序使用了多进程的架构，有时候需要在子进程被启动后非常早的阶段就进行调试，比较常见的极端情况是要调试子进程的`main()`函数，MSVS上有[插件](https://marketplace.visualstudio.com/items?itemName=vsdbgplat.MicrosoftChildProcessDebuggingPowerTool)可以在同一个调试环境同时挂载父进程和子进程进行调试，WinDBG在启动被调试程序时自带选项支持同时调试父子进程，但就我使用下来的体验发现，这时调试器的性能会变得非常差，非常影响心情和调试效果。也有比较low的办法，就是在子进程的`main()`函数开关加一个`MessageBox`，使其启动后用户有机会使用调试器attach子进程进行调试，但要改代码终归麻烦了点。

其实Windows系统提供了相应的机制可以应付这种需求，根据[这篇文章](https://learn.microsoft.com/en-us/archive/blogs/greggm/inside-image-file-execution-options-debugging#using-image-file-execution-options-with-vs-2005)和[这篇文章](https://learn.microsoft.com/en-us/visualstudio/debugger/debug-using-the-just-in-time-debugger?view=vs-2022#jit_errors)的说明，只要简单的改一下注册表，当Windows系统要启动某个可执行文件（即调用`CreateProcess` API）时，会检查注册表中是否有该可执行文件的项，如果有，则取得该项下的`Debugger`键值作为此次真正被启动的程序，同时将前面的可执行文件及命令行参数一起作为参数传递给该Debugger程序，由该Debugger程序负责启动并调试真正需要被调试的程序。

可以使用`vsjitdebugger.exe`程序调起MSVS进程调试，所以写一个简单的批处理文件修改注册表：

```powershell
@cd/d"%~dp0"&(cacls "%SystemDrive%\System Volume Information" >nul 2>nul)||(start "" mshta vbscript:CreateObject^("Shell.Application"^).ShellExecute^("%~nx0"," %*","","runas",1^)^(window.close^)&exit /b)
@echo off
set EXENAME=GFYProStartupCadIdentifier.exe
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%EXENAME%" /v Debugger /t REG_SZ /d vsjitdebugger.exe /f
reg add "HKLM\Software\WOW6432Node\Microsoft\Windows NT\CurrentVersion\AeDebug" /v Auto /t REG_DWORD /d 1 /f
@echo on
```

第一行是让本批处理文件以管理员权限运行。

第二行是取消控制台命令行回显。

第三行是设置要被调试的子进程可执行文件名，可以按自己需要修改为其他文件名。

第四行设置使用`vsjitdebugger.exe`进行调试。

第五行是为了规避某些情况`vsjitdebugger.exe`起不来子进程的问题，[这篇文章](https://learn.microsoft.com/en-us/visualstudio/debugger/debug-using-the-just-in-time-debugger?view=vs-2022#jit_errors)有说明。

第六行是恢复第二行被关闭的回显。第二行和第六行并不是必须的，只是个人习惯。

执行完该批处理文件后，就每当`GFYProStartupCadIdentifier.exe`程序要被启动时就会自动启动`vsjitdebugger.exe`，可以先在MSVS中打开该程序的源代码解决方案，在需要的地方打好断点，如果一切正常的话，`vsjitdebugger.exe`会显示这样的对话框用于选择MSVS会话进行调试：

![选择调试器](https://blogassets.ismisv.com/media/2024-06-16/choose-debugger.png)

选择相应的MSVS会话后，就会显示MSVS主窗口，如下：
![MSVS主窗口](https://blogassets.ismisv.com/media/2024-06-16/start-debugging.png)

点击“继续”按钮，就会从程序的起始点开始运行了，我们就可以开心地进行调试了。

如果不想再每次启动该程序就被自动调起调试器，就要把前面修改的注册表项还原回去，同样写个批处理文件双击执行一下即可：

```powershell
@cd/d"%~dp0"&(cacls "%SystemDrive%\System Volume Information" >nul 2>nul)||(start "" mshta vbscript:CreateObject^("Shell.Application"^).ShellExecute^("%~nx0"," %*","","runas",1^)^(window.close^)&exit /b)
@echo off
set EXENAME=GFYProStartupCadIdentifier.exe
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%EXENAME%" /f
reg delete "HKLM\Software\WOW6432Node\Microsoft\Windows NT\CurrentVersion\AeDebug" /v Auto /f
@echo on
```

