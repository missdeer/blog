---
title: 文章列表
layout: page
---

共 {{  site.posts.size  }} 篇文章：

{% assign counter = 0 %}
<ul class="listing">
{% for post in site.posts %}
  {% capture y %}{{post.date | date:"%Y"}}{% endcapture %}

  {% assign counter = counter | plus: 1 %}
  {% if year != y %}
    {% if counter > 1 %}
      <li class="listing-seperator">我在 {{ year }} 年共写了 {{ counter }} 篇文章</li>
      <hr class="post-list__divider">
    {% endif %}
    {% assign year = y %}
    {% assign counter = 0 %}
  {% endif %}
  <li class="listing-item">
    <time datetime="{{ post.date | date:"%Y-%m-%d" }}">{{ post.date | date:"%Y-%m-%d" }}</time>
    <a href="{{ post.url | prepend: site.baseurl}}" title="{{ post.title }}">{{ post.title }}</a>
  </li>
{% endfor %}
  <li class="listing-seperator">我在 {{ year }} 年共写了 {{ counter }} 篇文章</li>
</ul>
