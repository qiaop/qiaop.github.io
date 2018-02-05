---
title: Android系统启动流程
date: 2017-01-17 15:51:59
Author: codepeng
tags:
- Android
- csdn
categories:
- Android

---
作为一个Android应用开发工程师，Android系统的启动流程还是需要了解一下的。
前面我们讲了[计算机的启动流程](http://blog.csdn.net/qiao0809/article/details/52292143)和[Linux系统的启动流程](http://blog.csdn.net/qiao0809/article/details/52292499)，而Android作为一个基于Linux内核的系统，要了解清楚它的启动流程前面两位的流程也需要了解一下的。

<!-- more -->

好了，下面直接进入主题：

**流程图**

![这里写图片描述](http://img.blog.csdn.net/20160824094449225)

借助图片我们了解到，从Boot ROM开始到 init进程，这四个步骤是属于Linux的启动，从init进程才开始真正进入Android的世界。
我们逐步分析一下，希望读者对应几张图来理解：
## Step 1. 开启电源执行boot ROM
才开机时，CPU 处于未初始化状态，还没有设定内部时钟，仅仅只有内部 RAM 可用。当电源稳定后会开始执行 BOOT ROM 代码，这是一小块代码被硬编码在 CPU ASIC 中。

![开启电源执行Boot ROM](http://img.blog.csdn.net/20160824101524443)

 1. boot ROM 代码会引导 boot 媒介使用系统寄存器映射到 ASIC 中一些物理区域，这是为了确定哪里能找到 boot loader 的第一阶段
 2. 一旦 boot 媒介顺序确定，boot ROM 会试着装载 boot loader 的第一阶段到内部 RAM 中，一旦 boot loader 就位，boot ROM 代码会跳到并执行 boot loader

## Step 2. Bootloader
boot loader 是一个特殊的独立于 Linux 内核的程序，它用来初始化内存和装载内核到 RAM 中，桌面系统的 boot loader 程序有 GRUB，嵌入式系统常用 uBoot，
设备制造商常常使用自己专有的 boot loader 程序。

![Bootloader](http://img.blog.csdn.net/20160824101604455)

 1.  boot loader 第一阶段会检测和设置外部 RAM
 2. 一旦外部 RAM 可用，系统会准备装载主 boot loader，把它放到外部 RAM 中
 3. boot loader 第二阶段是运行的第一个重要程序，它包含了设置文件系统，内存，网络支持和其他的代码。在一个移动电话上，也可能是负责加载调制解调器的CPU代码和设定低级别的内存保护和安全选项
 4. 一旦 boot loader 完成这些特殊任务，开始寻找 linux 内核，它会从 boot 媒介上装载 linux 内核（或者其他地方，这取决于系统配置），把它放到 RAM 中，它也会在内存中为内核替换一些在内核启动时读取的启动参数
 5. 一旦 boot loader 完成会跳到 linux 内核，通常通过解压程序解压内核文件，内核将取得系统权限

## Step 3. The Linux kernel

Linux 内核在 Android 上跟在其他系统上的启动方式一样，它将设置系统运行需要的一切，初始化中断控制器，设定内存保护，高速缓存和调度

![Linux kernel](http://img.blog.csdn.net/20160824102956824)

 1. 一旦内存管理单元和高速缓存初始化完成，系统将可以使用虚拟内存和启动用户空间进程
 2. 内核在根目录寻找初始化程序（代码对应Android open source tree:system/core/init），启动它作为初始化用户空间进程
## Step 4. The init process
init进程是所有其他系统进程的 “祖母 ”，系统的每一个其他进程将从该进程中或者该进程的子进程中启动

![The init process](http://img.blog.csdn.net/20160824103926408)

 1. init进程会寻找 init.rc 文件，init.rc 脚本文件描述了系统服务，文件系统和其他需要设定的参数，该文件在代码：system/core/rootdir
 2. init进程解析 init 脚本，启动系统服务进程

init程序最核心的工作主要有3点：

 - 创建和挂载一些系统目录/设备节点，设置权限，如：/dev, /proc, and /sys
 - 解析 init.rc 和 init.<hardware>.rc，并启动属性服务，以及一系列的服务和进程。
 - 显示boot logo，默认是“Android”字样

其中，最重要的步骤是第二步，一系列的Android服务在这时被启动起来，其实Android系统的启动最重要的过程也就是各个系统服务的启动，因为系统所有的功能都是依赖这些服务来完成的，比如启动应用程序，拨打电话，使用WIFI或者蓝牙，播放音视频等等，只要这些服务都能正常地启动起来并且正常工作，整个Android系统也就完成了自己的启动。

这些服务包含2部分，一部分是本地服务，另一部分是Android服务，所有的这些服务都会向ServiceManager进程注册，由它统一管理，这些服务的启动过程介绍如下：
###（1）本地服务
本地服务是指运行在C++层的系统守护进程，一部分本地服务是init进程直接启动的，它们定义在init.rc脚本和init.<hardware>.rc中，如 ueventd、servicemanager、debuggerd、rild、mediaserver等。还有一部分本地服务，是由这些本地服务进一步创建的，如mediaserver服务会启动AudioFlinger, MediaPlayerService， 以及 CameraService 等本地服务。

我们可以通过查看init.rc和init.<hardware>.rc文件找出具体有哪些本地服务被init进程直接启动了，这些文件的位置：system/core/rootdir/

注意，每一个由init直接启动的本地服务都是一个独立的Linux进程，在系统启动以后，我们通过adb shell命令进入手机后，输入top命令就可以查看到这些本地进程的存在。
###（2）Android服务
init进程会执行app_process程序，创建Zygote进程，它是Android系统最重要的进程，所有后续的Android应用程序都是由它fork出来的。

Zygote进程会首先fork出"SystemServer"进程，"SystemServer"进程的全部任务就是将所有的Android核心服务启动起来。

## Step 5. Zygote and Dalvik(ART)
Zygote 被init进程启动，开始运行和初始化 dalvik 虚拟机

![Zygote and Dalvik](http://img.blog.csdn.net/20160824104133770)

## Step 6. The system server
系统服务是在系统中运行的第一个 java 组件，它会启动所有的 android 服务，比如：电话服务，蓝牙服务，每个服务的启动被直接写在 SystemServer.java 这个类的 run 方法里面
代码： frameworks/base/services/java/com/android/server/SystemServer.java

![The system server](http://img.blog.csdn.net/20160824104409345)

## Step 7. Boot completed
 一旦系统服务启动并运行，android 系统启动就完成了，同时发出 ACTION_BOOT_COMPLETED 广播


---------

