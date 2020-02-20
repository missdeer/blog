---
layout: post
image: https://img.peapix.com/9550137520935835171_320.jpg
author: missdeer
title: "试用基于有赞云的个人网站在线收款解决方案"
categories: Shareware
description: 试用基于有赞云的个人网站在线收款解决方案
tags: youzan pay alipay wechat
---

老早就注册[有赞云](https://console.youzanyun.com/register)了，之前随便玩了一下，感觉可以用，加上自己对web开发并不了解，就放下了。

今天突然心血来潮，用[Go折腾了一下](https://github.com/dfordsoft/youzanpay/)，用于[demo](https://pay.yii.li/)是很简单的，有赞的文档也还不错，虽然并不了解web开发，但拿别人的代码过来改改问题不大。

主要的工作流程为：

1. 从web上获取相关信息，比如价格、客户资料等，[创建收款二维码](https://www.youzanyun.com/apilist/detail/group_trade/pay_qrcode/youzan.pay.qrcode.create)
2. 有赞云返回二维码的id、url及base64编码后的图像信息，程序记录二维码id及用户信息的对应关系，后面有用
3. web页用js通过websocket获取二维码url或base64编码后的图像信息，并显示
4. 用户使用微信或支付宝扫一扫二维码进行支付
5. 扫完二维码后会跳转到有赞的一个页面，点击该页面上的支付按钮，有赞会[推送消息](https://www.youzanyun.com/docs/guide/3401/3455)到后台设置的回调地址上，状态是WAIT_BUYER_PAY
6. 用户支付完成后，有赞会再次[推送消息](https://www.youzanyun.com/docs/guide/3401/3455)，状态是TRADE_SUCCESS
7. 有赞推送的消息中只包含订单号，程序要[通过订单号反查](https://www.youzanyun.com/apilist/detail/group_trade/trade/youzan.trade.get)对应的二维码id，再查到用户信息完成一次交易

这个方案的优点是无需公司资质，无需接入支付宝和微信，可使用支付宝和微信扫码支付，支持储蓄卡和信用卡。

缺点是只能在网站上使用，在手机上不能唤起支付宝和微信app。另外据说有赞的风控比较严格，动不动就被冻结资金不能提现，需要找客服解冻。

程序代码在[这里](https://github.com/dfordsoft/youzanpay/)，代码很乱，仅供演示。在线demo在[这里](https://pay.yii.li/)，可以输入小额金额进行支付体验。