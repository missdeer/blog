---
image: https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/newgraph.png
layout: post
author: missdeer
featured: false
title: "使用Prometheus观察CoreDNS运行状况"
categories: Software
description: 使用Prometheus观察CoreDNS运行状况
tags: Prometheus CoreDNS
---
CoreDNS有一个官方的[prometheus插件](https://coredns.io/plugins/metrics/)，可以暴露一个http接口给[prometheus](https://prometheus.io/download/)使用。通过观察度量数据，可以了解到自己网络使用情况，有些比较有趣。

以我在[gist上的CoreDNS配置文件](https://gist.github.com/missdeer/5c7c82b5b67f8afb41cfd43d51b82c2d)为基础，加上prometheus插件：

```txt
. {
    prometheus
    ...
}
```

再运行CoreDNS，就会发现它在`localhost:9153`暴露了一个http接口，可以在浏览器里打开`http://localhost:9153/metrics`看一下，一堆数据，是给prometheus用的。

然后从Prometheus官网下载当前系统对应的安装包，解压，修改一下附带的配置文件`prometheus.yml`：

```yaml
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']

  - job_name: 'CoreDNS'
    static_configs:
    - targets: ['localhost:9153']
```

主要是添加了CoreDNS的job，target写对就行了，然后运行prometheus：

```shell
 ./prometheus --config.file=prometheus.yml
```

就能在浏览器里看到图表化的数据了，等一段时间，比如十几分钟或更长，可以看到更多信息，然后定制一些字段进行查看，比如我一天后通过以下URL进行查看：

```txt
http://localhost:9090/new/graph?g0.expr=coredns_cache_hits_total&g0.tab=0&g0.stacked=0&g0.range_input=1d&g1.expr=coredns_cache_misses_total&g1.tab=0&g1.stacked=0&g1.range_input=1d&g2.expr=coredns_cache_size&g2.tab=0&g2.stacked=0&g2.range_input=1d&g3.expr=coredns_dns_request_count_total&g3.tab=0&g3.stacked=0&g3.range_input=1d&g4.expr=coredns_dns_request_duration_seconds_count&g4.tab=0&g4.stacked=0&g4.range_input=1d&g5.expr=coredns_dns_request_type_count_total&g5.tab=0&g5.stacked=0&g5.range_input=1d&g6.expr=coredns_dns_response_rcode_count_total&g6.tab=0&g6.stacked=0&g6.range_input=1d&g7.expr=coredns_forward_request_count_total&g7.tab=0&g7.stacked=0&g7.range_input=1d&g8.expr=coredns_forward_response_rcode_count_total&g8.tab=0&g8.stacked=0&g8.range_input=1d&g9.expr=coredns_proxy_request_count_total&g9.tab=0&g9.stacked=0&g9.range_input=1d&g10.expr=coredns_redisc_hits_total&g10.tab=0&g10.stacked=0&g10.range_input=1d&g11.expr=coredns_ads_blocked_request_count_total&g11.tab=0&g11.stacked=0&g11.range_input=1d&g12.expr=coredns_ads_request_count_total&g12.tab=0&g12.stacked=0&g12.range_input=1d
```

可以得到以下内容：

![coredns_cache_hits_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_cache_hits_total.png)
![coredns_cache_misses_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_cache_misses_total.png)
![coredns_cache_size](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_cache_size.png)
![coredns_dns_request_count_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_dns_request_count_total.png)
![coredns_dns_request_duration_seconds_count](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_dns_request_duration_seconds_count.png)
![coredns_dns_request_type_count_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_dns_request_type_count_total.png)
![coredns_dns_response_rcode_count_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_dns_response_rcode_count_total.png)
![coredns_forward_request_count_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_forward_request_count_total.png)
![coredns_forward_response_rcode_count_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_forward_response_rcode_count_total.png)
![coredns_proxy_request_count_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_proxy_request_count_total.png)
![coredns_redisc_hits_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_redisc_hits_total.png)
![coredns_ads_blocked_request_count_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_ads_blocked_request_count_total.png)
![coredns_ads_request_count_total](https://cdn.jsdelivr.net/gh/missdeer/blog@gh-pages/media/2020-03-21/coredns_ads_request_count_total.png)

从以上图表中可以看出一些情况，例如：

1. 单机时redis几乎没用，家用的话不如去掉
2. 自带的cache插件就很有用，虽然有很多denial，但也有不少success的
3. 不需要设置太多的上游DNS Server，我在顶级forward上设了7个，实际上只看到5个有实际请求数据，所以大概2个就够了
4. 家中并不算特别多的设备，居然一天下来DNS请求也有5万次左右
5. 国内DNS解析的2个上游服务器负载很均衡，不像系统网络连接中虽然可以设置2个服务器，但常常逮住一只羊使劲薅
6. 有很多NXDOMAIN的记录，虽然很多是直接返回的，但我觉得需要给[bogus插件](https://github.com/missdeer/bogus)也加metrics支持了
7. 有大量A和AAAA的请求可以理解，有一些TXT大概是Let's Encrypt客户端发的，SRV大概是Cisco Jabber之类有Services Discovery功能的软件发的，还有一些PTR、SOA请求不知道是怎么回事
8. ads插件好像突然匹配不到黑名单了，不知道是不是bug了，感觉应该升级个版本试试