---
image:  https://blogassets.ismisv.com/media/2023-07-18/debian-nginx-webdav.png
layout: post
author: missdeer
featured: false
title: "Debian上使用Nginx搭建WebDav服务要点"
categories: network
description: Debian上使用Nginx搭建WebDav服务要点
tags: Debian Nginx WebDav
---

要点：

1. 不要用Nginx官方的源，而是用Debian的源安装Nginx
2. 一键安装Nginx及扩展：`sudo aptitude -y install nginx-full nginx-extras libnginx-mod-http-dav-ext libnginx-mod-http-auth-pam`
3. 配置要给zone分配内存：`dav_ext_lock_zone zone=webdav:10m;`

最容易出问题的就是以上3点，其他配置从网上抄一下就行，大体如下：

```txt
location / {
    root /home/missdeer/;
    dav_methods PUT DELETE MKCOL COPY MOVE;
    dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK;
    dav_access user:rw group:rw all:rw;
    dav_ext_lock zone=webdav;

    client_max_body_size 102400M;
    create_full_put_path on;
    client_body_temp_path /tmp/;

    set $dest $http_destination;
    if (-d $request_filename) {
        rewrite ^(.*[^/])$ $1/;
        set $dest $dest/;
    }

    if ($request_method ~ (MOVE|COPY)) {
        more_set_input_headers 'Destination: $dest';
    }

    if ($request_method ~ MKCOL) {
        rewrite ^(.*[^/])$ $1/ break;
    }

    auth_pam "Restricted";
    auth_pam_service_name "common-auth";

    index index.html index.htm index.php admin.php;
}
```

最后启用Nginx：`sudo systemctl restart nginx`。

如果起不来，先看一下配置文件是否有问题：`sudo /sbin/nginx -t`。