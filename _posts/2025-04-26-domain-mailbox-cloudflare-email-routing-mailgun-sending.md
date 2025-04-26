---
image: https://sendgrid.com/content/dam/sendgrid/legacy/2022/04/Untitled-design-2022-06-14T105831.696.png
layout: post
author: missdeer
featured: false
title: "免费搭建域名邮箱，使用Cloudflare、Mailgun和Gmail"
categories: network
description: 免费使用Cloudflare的Email Routing接收转发邮件到Gmail，使用Mailgun发送邮件
tags: Cloudflare Mailgun Gmail EmailRouting
---

以前QQ邮箱是支持域名邮箱的，不知从何时起就限制不让新增域名也不让新增邮箱地址了，相关业务全部被引导到腾讯企业邮箱上去了。但是要用腾讯企业邮箱就需要开通企业微信，开通企业微信要在腾讯申请创建企业，最后每次增一个邮箱地址，就要一个新的微信绑定和激活，实在是一笔不小的负担。而且我第一次这样走下来后，第二天我的主账号就不能登录了，人脸识别也不能通过，本来使用体验就不好，我只是想要域名邮箱，并不是真的要开公司，只能另外找解决方案了。

之前就听说过Cloudflare的邮件路由功能，刚好我的域名本来就是在Cloudflare上托管的，随便看了一点资料很快就能上手，直接在域名页面左侧栏选`Email Routing`，添加邮箱地址比如`missdeer@dfordsoft.com`，`Action`选`Send to an email`，`Destination`选目标邮箱比如我用`missdeer@gmail.com`。

![Email Routing](https://blogassets.ismisv.com/media/2025-04-26/email-routing.png)

如果是第一次设置邮件路由，Cloudflare会提示要增加几条DNS解析记录，直接点鼠标就能加上，以后就不用管了。等几分钟后DNS解析记录生效，用其他邮箱给`missdeer@dfordsoft.com`发邮箱试一下，一切正常的话在`missdeer@gmail.com`里就能收到邮件。如此可以添加多个邮箱地址，全部转发到Gmail里，可以在Gmail里添加filter，根据不同的收件邮箱地址，打上不同的label进行分类管理。这样就搞定了域名邮箱收邮件的需求。

然后是发邮件，点击Gmail页面右上角齿轮图标，再点击`See All Settings`,

![See All Settings](https://blogassets.ismisv.com/media/2025-04-26/gmail-all-settings.png)

切到`Accounts and Import`页面，可以在`Send mail as`栏添加不同的邮箱地址：

![Send mail as](https://blogassets.ismisv.com/media/2025-04-26/send-mail-as.png)

添加显示名称和邮箱地址：

![mail name](https://blogassets.ismisv.com/media/2025-04-26/name-info.png)

再设置发送件的SMTP服务器：

![SMTP server](https://blogassets.ismisv.com/media/2025-04-26/smtp-info.png)

图省事的话可以直接用Gmail的SMTP服务(smtp.gmail.com:587)，用当前Gmail账号信息即可，但这样会有个问题，用新增的邮箱地址发送的邮件在接收方会显示类似于`missdeer@dfordsoft.com (由missdeer@gmail.com代发)`这样的提示：

![Unexpected from name](https://blogassets.ismisv.com/media/2025-04-26/unexpected-from-name.png)

就会显得很不专业，我用域名邮箱的目的就是为了不让对方知道我其他邮箱的信息，不然我干脆直接全部用Gmail就行了。所以我用了Mailgun这个邮件发送服务，有免费额度，需求更大的话可以使用收费套餐。

注册一个Mailgun账号，这时已经可以用之前设置好的域名邮箱了，比如`missdeer@dfordsoft.com`，然后在后台管理页面左侧栏选`SENDING`-`Domains`添加域名`dfordsoft.com`：

![Mailgun SENDING Domains](https://blogassets.ismisv.com/media/2025-04-26/mailgun-add-domains.png)

这时Mailgun也会要求添加几个DNS解析记录，其中一条TXT记录是SPF验证信息，会与之前Cloudflare设置的重合，比如Cloudflare之前加了`v=spf1 include:_spf.mx.cloudflare.net ~all`，而Mailgun要你加`v=spf1 include:mailgun.org ~all`，这需要把两个记录合并成一个，即`v=spf1 include:_spf.mx.cloudflare.net  include:mailgun.org ~all`。然后点右上角`Verify`按钮，等记录状态变成`Active`了，就可以用默认邮箱地址`postmaster@dfordsoft.com`进行发邮件验证了。Mailgun会提供2种方式，一种是常见的SMTP协议，另一种是HTTP接口调用发邮件，一切正常的话，使用支持这些协议的软件应该就可以发邮件，对方收邮件了。然后添加新的邮箱地址比如`missdeer@dfordsoft.com`，并设置密码，Mailgun支持自动生成和手动设置2种方式，按自己喜好任选其中一种即可：

![SMTP Credentials](https://blogassets.ismisv.com/media/2025-04-26/mailgun-smtp-credentials.png)

最后就是回到Gmail设置页面，把Mailgun的SMTP服务器地址填进去，用户名密码就是上一步设置的邮箱地址和密码。现在再用Gmail以域名邮箱发送邮件，收件方就不会再看到`missdeer@gmail.com`这个地址了：

![Expected from name](https://blogassets.ismisv.com/media/2025-04-26/expected-from-name.png)

整个过程就是这样，Cloudflare和Mailgun都有免费额度，轻度使用绰绰有余。

