# HiNet
A lightweight http/https capture tool

iOS端轻量级网络抓包工具

### 为何造这个轮子？
> 目前iOS开发者，一般都是使用charles来抓包，本人也是一直使用charles，它很强大，造这个轮子当然不是为了替代charles，主要是为了某些场景下方便查看网络请求。
> 
> git上也有很多iOS的debug工具，保存的网络请求只能在手机端查看，毕竟是手机，有着操作不便、屏幕小的瓶颈，所以本工具就是为了使用电脑浏览器访问，使用B/S方式，
也无需安装任何Mac App。
>
> 而且，抓包https非常方便，不用像charles那样配置中间人证书，然后去信任它。当然，本工具只能抓此App内的所有请求，不能像charles那样抓整个手机的。
> 
> 不支持URLConnection的网络请求，因为不想支持。

### 集成 Cocoapods

```
pod 'HiNet' :git => 'https://github.com/JxbSir/HiNet.git', 
```

```objective-c
[[HiNetManager shared] start];
//log中会有可以访问的ip地址与端口，然后再浏览器中访问即可
```
