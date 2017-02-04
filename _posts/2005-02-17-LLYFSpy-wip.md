---
layout: post
title: LLYFSpy wip
categories: 
 - imported from CSDN
description: LLYFSpy wip
tags: 
---

今天发现，在XP 下，WH\_CALLWNDPROC 和WH\_CALLWNDPROCRET 这2个钩子函数，如果是空的，只是直接返回 CallNextHookEx，也会出错，看来不是我的程序问题了！万般无奈之下，仍旧换回BCB6来编译这个DLL，却意外地发现，竟然不出错了，只是似乎被探测程序运行更慢了：（也许只是先入为主的思想，心理感觉而已吧。

而且，相比3种不同的编译器（VC7.1 、BCC5.6.4 和GCC3.4.2）生成的DLL 文件大小，有很大不同。以都为Release 模式编译连接，GCC 的如果用了Strip，生成的最小， VC次之，BCC最大，其实BCB编译的DLL自己会加入好些东西，不但有其它的导出函数，还有其它的资源，对于一个小小的用来注入的DLL，资源就会占用好多比例，一个图标就是几KB，相比这一点，真是更喜欢GCC和VC，感觉上比较干净，但不知道怎么的，用GCC编译的DLL不能很好地工作，好像是用来数据共享内存映射部分和BCB编译的主程序有点不兼容，而VC似乎没有这个问题。本来还想用VC来编译这个用来注入的DLL的，还以为MS自己做出来的的编译器生成的DLL可能兼容性会更好一点点。不过话说回来，PC这个东东回来就不稳定，加上Windows，更不稳定，damn Windows！

昨天晚上被这个问题搞得心力交瘁，只好转向加了个对IHTMLWindow2 执行execScript 功能，竟然能支持JavaScript 和VBScript，只是我对这些都不熟，写了几条简单的语句来玩玩，真是牛啊，那些一个劲贬损IE，宣扬Firefox之类浏览器的人，真的明白IE的优缺点么，真的知道Firefox之类Geoko核心的浏览器的优缺点么……如果Windows上没有IE，网上不能运行的软件就会有一大堆，还会有好大一堆软件功能要损失一大块，真是佩服MS。

今天偶然发翻看到以前在论坛上看到修改BCB/Delphi 程序的任务栏菜单的帖子，于是把代码贴来用用，真的不错，以前写程序时，总是觉得任务栏菜单上缺了几项，感觉怪怪的。现在好了，像其它用VC，GCC写的程序一样了，作者已经不知道是哪位了，在这里先感激一下，代码如下：

\begin{verbatim}
class TForm1 : public TForm
{
__published: // IDE-managed Components
    void __fastcall FormShow(TObject *Sender);
private: // User declarations
protected:
    void __fastcall WndProc(TMessage &Message);
    void __fastcall CreateParams(TCreateParams&);
public:  // User declarations
    __fastcall TForm1(TComponent* Owner);
};

//-----------------------  CPP  -------------------------------

TForm1 *Form1;
//-------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------
void __fastcall TForm1::CreateParams(TCreateParams& Params)
{
    TForm::CreateParams(Params);
    Params.WndParent = NULL;
}
//--------------------------------------------------------
void __fastcall TForm1::WndProc(TMessage &Msg)
{
    if (Msg.Msg==WM_SYSCOMMAND && Msg.WParam==SC_ICON)
        ShowWindow(Handle, SW_SHOWMINIMIZED);
    else
        TForm::WndProc(Msg);
}
//------------------------------------------------------
void __fastcall TForm1::FormShow(TObject *Sender)
{
    ShowWindow(Application->Handle, SW_HIDE);
}
\end{verbatim}
如果程序只有这么一个自己写的窗体，这样就行了，如果要有其它的弹出的比如ModalDialog 时，还要在Show 的时候稍微加点代码。这样，就比较完美了\textasciicircum\_\textasciicircum 
