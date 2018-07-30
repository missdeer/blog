---
title: 关于这个博客
layout: commentablepage
---

从2003年开始写blog，最早在博客驱动，早已关闭，数据没导出。（2018年1月17日，偶然发现csdn上有[归档](http://blog.csdn.net/missdeer/article/month/2004/10)，但每篇文章都只能看到最前面一部分，csdn真是太垃圾了。

后来（2004年11月）csdn提供blog服务就开始在csdn上写，但是csdn的blog非常不稳定，在2006年时转移到blogspot。后来发现csdn上的blog账号被黑，有人在上面发了一堆广告，直接被运营商关闭，数据没导出。很久以后（2017年2月4日）偶然发现一个备份，于是导入。

开始blogspot还没被墙，没多久就墙了，但仍然坚持写到2009年。曾经有一段时间还在msn space和cppblog上同步csdn和blogspot发文章。

再之后（2010年1月）买了个空间自建Wordpress，不知道从何时起，域名被墙了，那时有个笑谈“不被认证的blog不是好blog”，但毕竟中文blog的主要流量都来自中国大陆，仍然坚持了一段时间，直到2012年下半年。

停了近1年半没写博客，2014年终于找到一个比较满意的Jekyll theme，在github上重新开始写blog，继续记流水账。

2017年8月将Pages托管到Coding.net，以期在中国大陆能获得更好的访问速度。

## 关于我

我的简历在[这里](https://minidump.info/fanresume/)。

<link rel="stylesheet" type="text/css" href="{{ "/css/pay.css" | prepend: site.baseurl }}">
<section class="read-more">
<div>
  <div style="padding: 10px 0; margin: 20px auto; width: 90%; text-align: center;">
    <div style="line-height:2.5;">感觉本博客不错，不妨小额赞助我一下！</div>
    <button id="rewardButton" disable="enable" onclick="var qr = document.getElementById('QR'); if (qr.style.display === 'none') {qr.style.display='block';} else {qr.style.display='none'}">
      <span>打赏</span>
    </button>
    <div id="QR" style="display: block;">
        <div id="wechat" style="display: inline-block">
          <a href="{{ "/assets/images/wepay.jpg" | prepend: site.baseurl }}" class="fancybox" rel="group">
          <img id="wechat_qr" src="{{ "/assets/images/wepay.jpg" | prepend: site.baseurl }}" alt="missdeer WeChat Pay">
          </a>
          <p>微信扫一扫</p>
        </div>
        <div id="wechat" style="display: inline-block">
          <a href="{{ "/assets/images/alipay.jpg" | prepend: site.baseurl }}" class="fancybox" rel="group">
          <img id="alipay_qr" src="{{ "/assets/images/alipay.jpg" | prepend: site.baseurl }}" alt="missdeer AliPay">
          </a>
          <p>支付宝扫一扫</p>
        </div>
    </div>
  </div>
</div>
</section>
