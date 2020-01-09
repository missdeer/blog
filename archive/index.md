---
title: 文章列表
layout: page
---

共 {{  site.posts.size  }} 篇文章：

{% assign counter = 0 %}
<ul class="listing">
{% for post in site.posts %}
  {% assign thisyear = post.date | date: "%Y" %}
  {% assign prevyear = post.previous.date | date: "%Y" %}
  {% assign counter = counter | plus: 1 %}
  <li class="listing-item">
    <time datetime="{{ post.date | date:"%Y-%m-%d" }}">{{ post.date | date:"%Y-%m-%d" }}</time>
    <a href="{{ post.url | prepend: site.baseurl}}" title="{{ post.title }}">{{ post.title }}</a>
  </li>
  {% if thisyear != prevyear %}
    {% if counter > 0 %}
      <li class="listing-seperator">我在 {{ thisyear }} 年共写了 {{ counter }} 篇文章</li>
      <hr class="post-list__divider">
    {% endif %}
    {% assign counter = 0 %}
  {% endif %}
{% endfor %}
</ul>
