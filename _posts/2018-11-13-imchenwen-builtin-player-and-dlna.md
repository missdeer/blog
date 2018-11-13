---
layout: post
title: "imchenwen进度：内置播放器和DLNA投屏"
categories: Shareware
description: imchenwen进度：内置播放器和DLNA投屏
tags: Qt MPV DLNA
---

大约一年半前因为感觉遇到解决不了的技术问题，于是imchenwen的坑就扔下不管了。上个月的时候突然意识到，妹子喜欢看网卡的视频，优酷腾讯芒果爱奇艺等等，但是因为身体原因捧着个手机或iPad看会觉得头疼，看电视就要好很多，所以就萌生了在电视机上看网络视频的想法。

说干就干，首先在淘宝花了一百多块钱买了个“山寨”投屏器，折腾了一下发现可以把优酷腾讯爱奇艺这几个大厂的app投屏过去，但是芒果app的投屏功能就不稳定，B站app压根没有投屏功能，更别说其他杂七杂八的网站和视频源了。

于是翻出一年半前就停滞开发的imchenwen，经过三周的折腾，基本实现了内置播放器和DLNA投屏的功能。目前内置播放器功能比较完善，可以流畅观看绝大多数的视频包括电视直播，DLNA投屏倒是能投了，但是进度条要么不好拖，要么干脆不能拖，不过目前勉强够用了。

一些screenshots：

![内置播放器](../../../media/2018-11-13/builtinplayer.jpg)

![选项设置](../../../media/2018-11-13/configuration.png)

![电视直播](../../../media/2018-11-13/livetv.png)

![地址解析](../../../media/2018-11-13/resolved.png)

大概说一下开发要点：

1. 内置播放器是通过引入libmpv解决的，github上有libmpv官方的Qt使用的[示例](https://github.com/mpv-player/mpv-examples/tree/master/libmpv/qt_opengl)，非常简单易用，但是用老式的被deprecated的opengl-cb接口，新的render API用法官方示例是没有，但我通过看另一个项目[MoonPlayer](https://github.com/coslyk/moonplayer)的用法，再自己连蒙带猜也试出来了，不直接用那代码的原因是imchenwen是基于QWidget的实现，MoonPlayer是基于QML的实现。后来发现另外有个[Media Player Classic Qute Theater](https://github.com/cmdrkotori/mpc-qt)的项目，就是直接用QWidget+render API的实现的，看到得晚了。

2. 无论是被deprecated的opengl-cb还是render API，视频输出都只能使用opengl-cb/opengl或libmpv，如果换成其他的，比如direct3d之类的，libmpv就会自己创建个窗口进行视频输出，所以不能用。网上倒是有OpenGL ES接口转DirectX或转Metal的库，可以试一下。

3. 一年半前遇到的一个问题是如果视频被切成多段，用播放器播放会断一下，这个问题可以通过合成一个m3u8，给mpv设置一个prefetch-playlist的参数解决。

4. mpv/libmpv对网络视频的支持比较好，提供了比其他播放器更多的参数，比如可以设置http的headers，可以单独设置referer，甚至可以设置cookie，更不用提http GET方法在URL后面加的query参数了。HLS流和RTSP流也能直接播放。

5. DLNA投屏限制比较多，据我观察下来，它能支持的URL和文件格式就比较严格，比如URL后面query参数比较多的话，基本不能播放，文件格式m3u8似乎就不行，大概只支持最常见的mp4、flv、ts等。也不知道是因为我买的投屏器比较山寨，还是说业界都是这么搞的。

6. 所以从网上弄来的视频地址有几种情况，要分别处理。最简单的一种情况是直接一个裸的诸如`http://www.xxx.com/path/media.mp4`这种URL，可以直接提交给投屏器播放。

7. 如果是带query参数的，比如`http://www.xxx.com/path/media.mp4?query1=value1&query2=value2&query3=value3`，需要把URL转换一下，我的办法是在本地起一个http server，把本地的URL比如`http://192.168.1.100:12345/path/media.mp4`提交给投屏器，http server接收到GET请求时，程序自己启动一个http client去请求视频原始的URL，把收到的视频数据从http server转发给投屏器。

8. 如果是一个m3u8，比如`http://www.xxx.com/path.m3u8`，则本地起一个http server，并提供一个投屏器支持的格式比如`http://192.168.1.100:12345/path/media.ts`，再程序自己去请求原始m3u8，解析出m3u8中视频的真实地址再继续请求回来视频数据，再转发给投屏器。

9. m3u8本身也有几种情况，一种是里面就是一组视频真实地址，诸如`http://www.xxx.com/path/media.flv?query1=value1&query2=valu2`等等，这种就照第7步做。另一种是里面是相对路径，比如`rpath/media.flv`这种，要先拼出绝对路径的URL，再照第7步做。还有一种是里面是另一个m3u8的地址，可能是绝对路径，或能是相对路径，在得到绝对路径后再请求m3u8内容，直到最后得到视频真实地址，再照之前的做。

10. 视频有可能是已经被分段的几个URL，需要自己拼成一个m3u8，再照第8步和第9步做。拼成m3u8时要加入`#EXT-X-TARGETDURATION:`和`#EXTINF:`，后面的数字可以随意，只要前者的比后者的大就行，播放器在收到视频数据时能自动计算出视频的真实时长。

11. 投屏器不像mpv有prefetch-playlist这样的参数，所以我现在的做法是把多段视频用[FFmpeg](https://www.ffmpeg.org/)合并成一段，全都只转封装成ts流，不转编码，那样就不会太耗时和耗CPU，我用2013Mid的MBA跑，也能即时转出来给投屏器用，基本不会卡，电视机分辨率不高的话，转个720p的就够了。

12. [FFmpeg](https://www.ffmpeg.org/)转出来的ts流直接存到本地硬盘文件，http server再读硬盘文件转发给投屏器，经过试验，http header中不要带`Content-Length`，而且`Content-Type`必须是`application/octet-stream`，投屏器才会不断地接收http server喂给的数据，其他文件格式、`Content-Length`或`Content-Type`都可能会导致投屏器要么干脆没反应，要么有声音没图像，要么只有前面一段内容。

13. 爱奇艺有视频有`.265ts`的格式，跟其他网站基本用H264的不同，用[FFmpeg](https://www.ffmpeg.org/)转封装要用不同命令。目前我分别用这两条目前转封装：

    ```bash
    ffmepg -y -protocol_whitelist "file,http,https,tcp,tls" -i http://127.0.0.1:12345/media.m3u8 -c:v libx265 -c:a aac -copy ts media.ts
    ```

    ```bash
    ffmepg -y -protocol_whitelist "file,http,https,tcp,tls" -i http://127.0.0.1:12345/media.m3u8 -c:v copy -c:a aac -copy ts media.ts
    ```

    对[FFmpeg](https://www.ffmpeg.org/)了解不多，不知道有没有更好的办法。

14. 现在的问题是：不支持HLS/RTSP投屏；没有手机端；mac上用QWebEngine太重了，用系统的WebView大概会好一些。