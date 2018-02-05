---
title: android 组件化
date: 2017-11-08 10:20:45
tags:
- 架构
categories:
- Android

---

## 组件化与插件化
### 什么是插件化
#### 插件化主要概念介绍

 - 主要特点：即插即用（U盘），apk 分为宿主和插件部分，插件在需要的时候才加载进来
 - 原理：ClassLoader
 - 类似的方案：热修复，热更新，热部署
 
#### 插件化的作用
 -  减少主包大小
 -  编译提速
 -  可选模块按需下载
 -  并行开发，独立Testing
 -  崩溃隔离

#### 插件化有什么限制

- 系统适配，Dex的加载与系统版本依赖严重，可能会导致新版SDK不支持等问题
- 需要预先注册权限，宿主的权限要多于插件的权限, 否则会权限不足
- 自己实现包管理服务PMS
- 使用方法与原生方式差异大，插件内部对资源的访问只能通过自己定义的方式

### 什么是组件化
#### 主要概念
组件化（模块化）是在软件开发架构层面的一个概念，在android中的组件化是指将一个app分成多个模块，每个模块都是一个组件（Module）。

<!-- more -->

### 组件化与插件化的区别
组件化开发就是将一个app分成多个模块，每个模块都是一个组件（Module），开发的过程中我们可以让这些组件相互依赖或者单独调试部分组件等，但是最终发布的时候是将这些组件合并统一成一个apk，这就是组件化开发。

插件化开发和组件化开发略有不用，插件化开发时将整个app拆分成很多模块，这些模块包括一个宿主和多个插件，每个模块都是一个apk（组件化的每个模块是个lib），最终打包的时候将宿主apk和插件apk分开或者联合打包。

## 为什么要有组件化
假如一个app工程只有一个组件，随着app业务的壮大模块越来越多，代码量超10万是很正常的，这个时候我们会遇到以下问题：

- 稍微改动一个模块的一点代码都要编译整个工程，耗时耗力
- 公共资源、业务、模块混在一起耦合度太高
- 不方便测试

## 组件化的作用
- 模块间解耦、重用
- 缩短编译调试时间，比较大的项目改一个bug，编译得5-10分钟
- 功能动态插拔，例如更换推送方案，直接删除添加moudle
- 多团队并行开发测试（可单独编译，打包）

## 如何实现组件化
- 代码解耦，分割整体
- 组件单独调试
- 组件之间数据传递
- UI页面跳转
- 组件的生命周期
- 集成调试
- 代码隔离

### 代码解耦
将庞大的代码进行拆分，使用AndroidStudio中moudle功能，将代码拆分为多个moudle。将moudle进行区分：

- 底层基础库（library），将被其他组件引用。
- 业务组件（component），完整的业务逻辑功能模块。
- 主moudle，负责拼装组件形成一个完整的app。

### 组件单独调试
- 单独调试

单独调试比较简单，只需要把apply plugin: 'com.android.library'切换成apply plugin: 'com.android.application'就可以，但是我们还需要修改一下AndroidManifest文件，因为一个单独调试需要有一个入口的actiivity。

- 设置一个变量isRunAlone，标记当前是否需要单独调试

设置一个变量isRunAlone，标记当前是否需要单独调试，根据isRunAlone的取值，使用不同的gradle插件和AndroidManifest文件，甚至可以添加Application等Java文件，以便可以做一下初始化的操作。

- 避免不同组件之间资源名重复

为了避免不同组件之间资源名重复，在每个组件的build.gradle中增加resourcePrefix "xxx_"，从而固定每个组件的资源前缀。

示例：

```
if(isRunAlone.toBoolean()){    
apply plugin: 'com.android.application'
}else{  
 apply plugin: 'com.android.library'
}
.....
    resourcePrefix "readerbook_"
    sourceSets {
        main {
            if (isRunAlone.toBoolean()) {
                manifest.srcFile 'src/main/runalone/AndroidManifest.xml'
                java.srcDirs = ['src/main/java','src/main/runalone/java']
                res.srcDirs = ['src/main/res','src/main/runalone/res']
            } else {
                manifest.srcFile 'src/main/AndroidManifest.xml'
            }
        }
    }

```

### 组件之间数据传递
在这里我们采用接口+实现的结构。每个组件声明自己提供的服务Service，这些Service都是一些抽象类或者接口，组件负责将这些Service实现并注册到一个统一的路由Router中去。如果要使用某个组件的功能，只需要向Router请求这个Service的实现。

- 接口+实现的结构
- Router功能

### 组件之间的UI跳转
Android中UI路由的主流实现方式：
一般通过短链的方式来跳转到具体的Activity，每个组件可以注册自己所能处理的短链的scheme和host，并定义传输数据的格式。然后注册到统一的UIRouter中，UIRouter通过scheme和host的匹配关系负责分发路由。

### 组件的生命周期
每个组件添加几个生命周期状态。每个组件增加一个ApplicationLike类，里面定义了onCreate和onStop两个生命周期函数。
- 加载

每个组件负责将自己的服务实现注册到Router中，其具体的实现代码就写在onCreate方法中。主项目调用这个onCreate方法就称之为组件的加载，因为一旦onCreate方法执行完，组件就把自己的服务注册到Router里面去了，其他组件就可以直接使用这个服务了

- 卸载

调用ApplicationLike的onStop方法，在这个方法中每个组件将自己的服务实现从Router中取消注册。不过这种使用场景可能比较少，一般适用于一些只用一次的组件。

- 降维

比如一个组件出现了问题，我们想把这个组件从本地实现改为一个wap页

### 集成调试

每个组件开发完成之后，发布一个relaese的aar到一个公共仓库，一般是本地的maven库。然后主项目通过参数配置要集成的组件就可以了。

### 代码隔离
我们希望只在assembleDebug或者assembleRelease的时候把aar引入进来，而在开发阶段，所有组件都是看不到的，这样就从根本上杜绝了引用实现类的问题。

gradle来解决。创建一个gradle插件，然后每个组件都apply这个插件。

```
//根据配置添加各种组件依赖，并且自动化生成组件加载代码
 if (project.android instanceof AppExtension) {
            AssembleTask assembleTask = getTaskInfo(project.gradle.startParameter.taskNames)
            if (assembleTask.isAssemble
                    && (assembleTask.modules.contains("all") || assembleTask.modules.contains(module))) {
              //添加组件依赖
               project.dependencies.add("compile","xxx:reader-release@aar")
              //字节码插入的部分也在这里实现
            }
}

    private AssembleTask getTaskInfo(List<String> taskNames) {
        AssembleTask assembleTask = new AssembleTask();
        for (String task : taskNames) {
            if (task.toUpperCase().contains("ASSEMBLE")) {
                assembleTask.isAssemble = true;
                String[] strs = task.split(":")
                assembleTask.modules.add(strs.length > 1 ? strs[strs.length - 2] : "all");
            }
        }
        return assembleTask
    }

```

---
### 参考链接
[Android彻底组件化方案实践](http://www.jianshu.com/p/1b1d77f58e84)
