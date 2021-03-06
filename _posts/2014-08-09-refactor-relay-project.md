---
layout: post
image: https://img.peapix.com/1602789425534448580_320.jpg
author: missdeer
title: "重构Relay项目"
categories: Job
description: 重构Relay项目
tags: coding socket network multithread Boost asio
---
前面提到过，因为了读了一点《Linux多线程服务端编程》，觉得自己对网络编程有了更多的了解，可以对公司里负责开发维护的那个小项目动手重构了。这个小项目从功能上简单说来，就是个流量转发器，也可说成是个中断器，所以项目名称就叫Relay了。几乎每个刚听到这句话的人，都会第一时间发出疑问：这种功能网上开源代码或现成工具应该有很多，比如nginx就有类似的功能，为什么要自己做一个？答案可以从两个方面来回复，一种霸道无理点的说法是，这是公司策略，这个理由足以堵住所有质疑者的嘴巴。另一种理性点的说法是，自己做可控性好，可扩展性也好，比如我们要有实时的流量统计，我们要自定义高效的传输协议，像nginx的http传输性能不能完全满足我们的需求等等。

我简单介绍一下这个项目的架构，因为确实很简单，所以也算不上泄漏公司机密。首先，是有n个用于做流量转发的r进程，就像nginx会有n个worker进程。其次因为要统计实时流量变化，所以会有一个独立的d进程收集那些r进程上报过来的流量信息，并把这些信息汇总提供给其他需要使用这些信息的进程。再次有个提供给Web端操作的接口程序，这之前一直是用FastCGI实现的，就叫c吧，用户可以在浏览器上查看某台机器上有多少个r进程，每个r进程的数据源和数据宿地址端口及使用协议等信息，当然还有流量统计信息，最重要的是用户还可以增加或删除r进程。再然后，公司有一个专门收集各个项目在线上运行情况的服务，所以r的运行情况会需要周期性上报，于是有另一个进程就称为t吧，来做这个事。很明显，t和c所需要的信息都是从d处得来的。最后，有一个l进程会负责r进程的创建和销毁，同时也兼任了watchdog的任务，用户从Web端增加或删除r进程，就是把命令通过c传给d，再转给l来实现的。这就是整个的架构了。

这个项目从开始开发到现在已经超过1年半了，在线上的运行时间最长的也超过1年了，当然中间已经经过很多个版本升级。就我个人看来，这个项目的架构没什么大问题，有问题的基本都是实现上的问题，当然升级版本也已经改了不少。例如：

- 刚开始接手这项任务时，我没有任何socket编程经验，但我知道Boost里有asio啊，一看这个的需求明显是个高吞吐的应用，无论选什么技术对我来说都是从0开始，于是我就用asio来实现r了。最早还只有转发http流量的需求，于是花了一周时间实现了一个，还没做任何错误处理的。之后测试证明，正常情况下，确实运作得很好，latency也表现良好。但是，世界上最怕的就是“但是”，不正常情况下，比如运行一段时间后，会出现再也连接不上数据源的情况，socket销毁重建都没用，只有进程销毁重建才行，这明显让人诟病。在我还在绞尽脑汁怎么解决这个问题时，CTO在他们开会时花了半个小时用简单的select模型写了个相同功能的程序，虽然后面仍然花了几天时间用于调试修正各种发现的问题，但这件事一直成为后来Director嘲讽我的一个理由：你哗啦哗啦写一个星期还有问题，人家开会的时间一哈哈就写出来了。这件事情也让我从此对Director的观感差到了极点，你让我一个普通开发人员跟CTO比技能，我拿多少工资他拿多少工资，再说了，你分配我一从来没做过这事的人去做这事，这最大的责任应该是你失职先吧？扯远了，尽管Director的人品差从后面的一系列事件中确实不断得到有力证明。然后我就想既然你觉得CTO的程序好，那我就全盘接过来呗。一直到现在，那块代码除了我加了些流量统计的功能，就仍然是CTO写的那个样子。

- 后来因为http协议的抢带宽能力不够强，在物理带宽足够的情况下，仍然会有视频会要时不时缓冲一下的情况，于是公司自己搞了一套多链路传输的协议。这个协议的实现是另一个同事做的，也是用了简单的select模型（简直是一招鲜），实际运行抢带宽能力确实比http好得多，缺点是latency要差很多，而且很占CPU。这位同事的代码风格很诡异，以至于我到现在都没从头到尾看过那份代码。

- c用了FastCGI模型，虽然开发简单，但似乎网上能找到的资料极少。比如在Linux下居然是要通过lighttpd项目口的spawn-fcgi脚本来启动并指定服务端口的，而Windows下不能用Linux下的那套accept循环，因为用了就不能正常接受连接。而在Linux下用的那套API是不用一个类似context的结构的，于是就每个请求的处理都是阻塞的，下一个请求得等到前一个请求完成后才能被接受并处理，于是对于有些耗时的操作，比如增加r进程，每个请求得花3-4秒钟（这中间也包括了效率低下的IPC），要测试增加几十个r进程得花好久！更严重影响用户体验的是，在一个耗时较长的请求完成之前，Web上就因为取不到统计信息，只能显示空白！

- t是用来向公司另一个自建服务器以http POST的方式上报数据的，而那个服务器因为没实现好，处理并发连接能力极其低下，那时那个开发人员还跟我说网上有几千台机器在同时给他发数据，我还觉得这处理不过来也不是特别不能接受，还可以理解，直到前不久另一个同事告诉我，那时他们连200个并发连接都撑不住，OMG！可那时我不知道啊，我的t进程每秒钟给它POST一段数据，我想尽办法也不能让它保证每秒钟POST的数据对方都能准确收到，我一直以为是我的问题，各种长连接，短连接方法全都试了，总是过不了一分钟两分钟，就会丢掉几个POST。后来旁边的同事告诉我一个比较耍赖的办法：不自己POST了，把数据写到一个临时文件中，调用wget来POST这个临时文件，在整个公司的共识中，还是很信赖wget的稳定性和可靠性的，如果这种情况对方还是收不到数据，只要我能证明我确实让wget去POST正确的数据了，那责任就在那个服务器了。从那以后那个服务器开发人员再也不敢随便栽赃给我了，显然他后面一直为如何提高并发能力而头疼。

- t对面的服务器怎么都提高不了并发能力，于是CTO给出了个很无奈的主意：原先http POST的接口让客户端都改成半分钟或一分钟一次，而不是原来的一秒一次，另外增加一个UDP服务端口，让客户端通过UDP端口上报信息，每秒2次，并且上报格式由xml改成binary，以减小传输数据量。这个过程中比较狗血的是，服务器开发人员跑来问我们，这个binary数据怎么解析（格式是他跟CTO一起定的），他的理由是做JAVA的从来不处理binary，所以不会。又扯开了，然后t就加UDP支持吧，由于之前http上报功能的教训，我直接找了个外部的程序来发UDP报文，因为Relay后来已经变成一个纯粹的Linux项目了，所以我考察了netcat，socat后，最终选择了bash，是的，bash是可以直接给指定的TCP或UDP地址和端口发数据的。这个方案总算安安稳稳地上线了，不过直到前不久，才发现我这个实现引起的一个大问题！公司的网管老说我的程序有严重的内存泄漏问题，我自己的经验和QA的测试结果都没遇到，我比较仔细地检查了遍代码中动态内存分配的地方，觉得没可能有内存泄漏的！后来网管说，这种泄漏用free命令或top命令看不出来的，要看`cat /proc/meminfo | grep Slab`项，你看这生产环境的监控历史记录，半年来一点点增长，最后到8G，内存用完了！刚遇到这问题我还一点头绪都没有，后来在网上搜了一下，还真有跟我几乎一模一样的情况，[这篇文章](http://www.cnblogs.com/panfeng412/p/drop-caches-under-linux-system-2.html)基本解释了原因和处理办法。但要根治，仍然得改程序，不能再频繁写临时文件了。

- 最早r的功能简单，所以配置文件用于描述r的命令行参数也简单，我只用了个类似JAVA properties的格式就完了，后来r的功能增加，配置文件的格式也越来越复杂，继续用JAVA properties显得有点繁琐，于是改为XML格式，无论可读性还是描述能力都大大增强。但这对l的要求也增加了，不能像一开始那样很直观地读写配置文件了。我灵机一动，发现iterator模式比较适合这种场景，因为每一条r的配置项就是一条记录，里面有n个r的配置项，要增删改查，iterator在STL中的表现就已经表明了自己的能力。花了大约2周时间，确实效率很低，终于把它改完了，还能适配STL的算法来使用。l同时还是个watchdog，这个任务在Windows下的实现还比较直观，任何一个进程无论是不是你创建的，你只要知道进程ID，都有API等它结束。但Linux下，或者说POSIX系统下似乎没有一个统一有效的解决办法。POSIX下对自己创建的子进程，可以waitpid来等待，但如果不是子进程就不行，为什么会有不是子进程的情况呢？因为l自己也可能会异常退出，再被启动时就得继续它前世的任务。然后我就用了一个比较低执行效率的办法：每隔半秒或1秒去检查一下那些进程还活着么。真不舒服啊！不过现在我知道了一些更有效的办法，下面再说。l的这种做法还有一个不好的地方，就是每个被监视进程，l都会创建一个单独的线程用来监视它。也就是说l是个多线程程序，而且可能线程还很多。同时l在POSIX系统下会fork子进程。我是才知道一般人们都会尽量避免多线程程序fork新进程，主要原因是新fork出来的进程只有fork所在线程还活着，其他线程都蒸发了，如果其他线程之前加了锁，就没机会去掉锁，当前线程如果再去加那个锁，就完蛋了。好在l的那些线程基本互不相干，没出现这种问题。但自从知道多线程程序不提倡fork以来，我就一直吃不香睡不好啊！

- d的焦点主要在IPC上，d除了IPC就没其他什么事了，它自己本身没什么业务逻辑。最早IPC格式是XML文本，后来我总觉得XML的生成和解析比较慢，虽然已经用了非常快速的[rapidxml](http://rapidxml.sourceforge.net)库。于是我凭自己的想象，直接把格式换成[Google Protocol Buffer](http://code.google.com/p/protobuf/)，实测证明两者在消息内容序列化和反序列化的耗时差不多！主要的逻辑函数测试耗时都在10ms左右。不过用protobuf的一个好处是，代码可读性比用XML要好，因为protobuf是直接对本地语言，我是用C++，的结构体进行读写操作。格式没问题了，协议交互是我认为d现在最大的问题。d的IPC是用TCP socket形式实现的，d被实现成一个TCP server，r/l/c/t都作为client连上来，发送数据过来或查询数据而去。这种形式的问题在于，主动权全都在client侧，client想给数据了就给数据，想要数据了才收数据。以当前的实现，比如用户在Web上做了一个操作，命令从c发到d，而d是不会主动将该命令发给l的，只有看l心情好的时候自己要找d要命令时，d才会将命令给它。这也就是我前面说到c的有些操作很耗时，有很多时间是浪费在效率低下的IPC上了。

知道了问题所在，可以开始着手改进了，这一次的重构也许会花很多时间，但好在目前在生产环境上运行的版本基本能满足需要，所以没有进度压力，我可以慢慢来。用前些天在网上看到的[一句话](http://www.zhihu.com/question/24665029/answer/28567915)来形容，服务器端开发就是把代码精简、效率最优、没有冗余作为毕生追求。以此为目标，我觉得我可以做一些事情了。

- 把几个程序全都改成单线程的！虽然我看的是《Linux**多线程**服务端编程》，但是我从中嗅出来浓浓的“单线程好~单线程好~”的味道（纯属个人观点，请勿较真）！我用`pstree -p`一看，列出长长超过一屏的线程我就觉得不舒服，用`pstree -p $(pidof nginx)`一看，才**一个**线程！！！多么优雅，多么简洁，多么洒脱啊！！！

- 用了单线程除了实现简单，还能带来一些额外的好处，比如整个程序再也不需要**锁**这种东西了！比如不同模块间，可以肆无忌惮地通过共享内存传递消息了（是的，Go语言因为goroutine特别轻量，创建goroutine成本特别低，所以会倾向大量使用goroutine，而与此同时，Go的开发者们则提倡通过消息来共享内容）！

- 所有socket都用Boost.asio实现，asio提供了跨平台的proactor模式实现，我觉得我现在对proactor有了新的理解，可以比以前更好地使用它了。当前项目中只有IPC是全用asio实现的，极偶尔的也会出现点小问题，但不影响正常工作了，现在再重构，精心设计之下肯定能取得更好的效果。r这种核心业务模块，对高吞吐的要求那么迫切，把select换成Linux下的epoll，换成Windows下的完成端口，换成BSD系下的kqueue，不是更好吗！

- 把c的FastCGI模式换掉，写个纯粹的http server来暴露接口就可以了，反正web一直是通过nginx套在c前面提供RESTful的API来完成任务的。一来可移植性好，部署方便，二来响应比FastCGI快。

- 把t通过创建外部程序进程来发送http POST和UDP数据包的逻辑改成自己程序内socket实现，这样可以修正Slab泄漏的问题，而且依赖少。

- l的监控进程逻辑可以全部改掉，不过仍然得针对不同的系统平台做分别的适配。比如Windows下可以用RegisterWaitForSingleObject，系统会创建新线程在进程结束时回调你的方法来通知你。在Linux下可以用netlink，像普通网络socket一样select事件，等待进程退出的事件到达。在BSD系下可以用kqueue来等待进程退出的事件，有点像netlink的做法。这样原本一个进程一个监控线程的办法就不需要了，我这边最多只要有一个线程，可以监控到所有无论是否子进程的退出消息。至于其他系统，就不考虑了吧。

- 然后是IPC协议要改，要改成server侧可以即时push的形式，而不是等client主动定时轮询。这个的好处就是减小IPC的latency，这样原本有一部分逻辑为了加快速度，是l和c协商操作一块共享内存的，现在也可以通过IPC传递了，形式上的统一更优雅美观。

- 最后，因为IPC效率提高，c响应速度和并发能力提高，在l侧就要注意操作配置文件就得保证是串行的，如果l改成单线程的话，串行是没问题的，但操作顺序是没法保证的，这我一时间也想不出什么好的办法，或许压根就不用管？

先就想到这么多，已经要花很多时间才能做完了。
