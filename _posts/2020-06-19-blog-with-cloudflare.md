---
image: https://img.peapix.com/217848e7383248d486b539af576ce8d4_320.jpg
layout: post
author: missdeer
featured: false
title: "折腾Blog及Cloudflare加速优化"
categories: Blog
description: 新学到的Cloudflare玩法，以及blog再折腾
tags: Blog Cloudflare
---
虽然现在写blog的频率大不如前，但折腾blog仍然是件很有趣的事，以及新学到些Cloudflare玩法。

我的blog是用Jekyll的，本来直接提交到GitHub pages就可以了，但是GitHub pages的Jekyll引擎限制了不能使用plugins，而我几个月前的某一天心血来潮写过简单的插件用于嵌入PlantUML代码直接渲染，所以之后每次提交GitHub都会收到Jekyll build失败的邮件通知。拖了这么久，得益于GitHub Actions的免费使用，这次终于花了点时间改了一下blog。

首先是把blog从gh-pages分支切换到master分支，删除原gh-pages分支，然后创建一个GitHub Actions的[workflow](https://github.com/missdeer/blog/blob/master/.github/workflows/publish.yml)，在workflow中依次安装好Go和Ruby环境，分别用于build插件/第三方工具和Jekyll，最后将生成的_site目录强行push到gh-pages分支，这样GitHub就会直接通过http serve这些静态文件，可以通过`https://missdeer.github.io/blog/`浏览。

GitHub pages本身是支持绑定自定义域名的，还能提供SSL，由于众所周知的原因，在国内直连的速度非常非常慢。之前我是直接将自定义域名托管在Cloudflare上，开proxy，这样访问者实际是走了Cloudflare的网络。但因为用的free plan，所以给的两个IP是（国内？）速度不佳的线路。Cloudflare号称在全世界一两百个城市有节点，并且事实上只要能将域名解析到合适的IP，就能享受到更优质的线路，即使是free plan也是如此。

这就要用到Cloudflare Worker这项服务。此服务每天可以免费提供10万次请求，每个账号最多可以创建30个Worker。我创建了一个worker，网上找了一段代码略作修改，实现http/https反向代理，代码如下：

```js

// Replace texts.
const replace_dict = {
    '$upstream': '$custom_domain',
    '//google.com': ''
}

addEventListener('fetch', event => {
    event.respondWith(fetchAndApply(event.request));
})

async function fetchAndApply(request) {
    let response = null;
    let url = new URL(request.url);
    let url_hostname = url.hostname;
    let user_agent = request.headers.get('user-agent');
    let upstream = "minidump.info"
    let upstream_path = '/'
    let disable_cache = false

    if (user_agent == undefined || user_agent == null || user_agent == "" || await device_status(user_agent)) {
        let domainMap = new Map([
            ["minidump.info", "missdeer.github.io"],
            ["www.minidump.info", "missdeer.github.io"]
        ]);
        upstream = domainMap.get(url.hostname);
    } else {
        let domainMobileMap = new Map([
            ["minidump.info", "missdeer.github.io"],
            ["www.minidump.info", "missdeer.github.io"]
        ]);
        upstream = domainMobileMap.get(url.hostname);
    }

    if (upstream == undefined) {
        let responseHeaders = new Headers();
        let responseStatus = 404;
        return new Response("404 not found", {
            responseStatus,
            headers: responseHeaders
        });
    }

    url.protocol = 'https:';

    var upstream_domain = upstream;

    url.host = upstream_domain;
    if (url.pathname == '/') {
        url.pathname = upstream_path;
    } else {
        url.pathname = upstream_path + url.pathname;
    }

    let method = request.method;
    let request_headers = request.headers;
    let new_request_headers = new Headers(request_headers);

    new_request_headers.set('Host', upstream_domain);
    new_request_headers.set('Referer', url.protocol + '//' + url_hostname);

    let original_response = await fetch(url.href, {
        method: method,
        headers: new_request_headers
    })

    connection_upgrade = new_request_headers.get("Upgrade");
    if (connection_upgrade && connection_upgrade.toLowerCase() == "websocket") {
        return original_response;
    }

    let original_response_clone = original_response.clone();
    let original_text = null;
    let response_headers = original_response.headers;
    let new_response_headers = new Headers(response_headers);
    let status = original_response.status;

    if (disable_cache) {
        new_response_headers.set('Cache-Control', 'no-store');
    }

    new_response_headers.set('access-control-allow-origin', '*');
    new_response_headers.set('access-control-allow-credentials', true);
    new_response_headers.delete('content-security-policy');
    new_response_headers.delete('content-security-policy-report-only');
    new_response_headers.delete('clear-site-data');

    if (new_response_headers.get("x-pjax-url")) {
        new_response_headers.set("x-pjax-url", response_headers.get("x-pjax-url").replace("//" + upstream_domain, "//" + url_hostname));
    }

    const content_type = new_response_headers.get('content-type');
    if (content_type != null && content_type.includes('text/html') && content_type.includes('UTF-8')) {
        original_text = await replace_response_text(original_response_clone, upstream_domain, url_hostname);
    } else {
        original_text = original_response_clone.body
    }

    response = new Response(original_text, {
        status,
        headers: new_response_headers
    })

    return response;
}

async function replace_response_text(response, upstream_domain, host_name) {
    let text = await response.text()

    var i, j;
    for (i in replace_dict) {
        j = replace_dict[i]
        if (i == '$upstream') {
            i = upstream_domain
        } else if (i == '$custom_domain') {
            i = host_name
        }

        if (j == '$upstream') {
            j = upstream_domain
        } else if (j == '$custom_domain') {
            j = host_name
        }

        let re = new RegExp(i, 'g')
        text = text.replace(re, j);
    }
    return text;
}


async function device_status(user_agent_info) {
    var agents = ["Android", "iPhone", "SymbianOS", "Windows Phone", "iPad", "iPod"];
    var flag = true;
    for (var v = 0; v < agents.length; v++) {
        if (user_agent_info.indexOf(agents[v]) > 0) {
            flag = false;
            break;
        }
    }
    return flag;
}
```

懂JS的应该很容易看明白，代码逻辑很简单，只要将面向用户的域名和目标域名分别写入`Map`中，这里还区分了桌面和移动端，以后要做更多的反代也只要继续在`Map`加条目就行了。

保存并部署worker后，到域名设置那里有个`Workers`页面，点`Add route`，添加路由，我的情况是`route`填`*minidump.info/*`，`Worker`通过下拉框选择前面保存的worker名字`reverseproxy`，然后保存。

最后，到`DNS`页面修改`minidump.info`的A记录，Cloudflare最有名的IP大概是`1.1.1.1`和`1.0.0.1`了，可以设成这两个中的任意一个，但事实上在很多地区这两个IP不是被无脑设坏了，就是被墙了，所以可以改成其他的IP，网上随便搜一下就能发现大量的文章列出了Cloudflare的IP，自己挑一个设上，再到[17ce](https://www.17ce.com/)看一下效果，大概比free plan自动给的IP好一点吧。

实际用下来的感觉，Cloudflare在国内只能说是能凑合用，再怎么选择IP，总是有不少地区连不上或超时等等。从17ce的结果来看，CDN效果还没有Amazon的CloudFront好。估计Cloudflare在业余玩家中比CloudFront流行的原因是它的免费额度够高。