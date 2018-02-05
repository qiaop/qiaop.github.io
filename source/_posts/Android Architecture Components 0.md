---
title: Android Architecture Components 使用
date: 2017-08-10 14:49:19
tags: 
- Architecture
- 翻译
categories:
- Android

---

## Adding Components to your Project
> 注意：架构组件目前仍然是alpha版本。 在1.0版本之前可能有更改。
架构组件可从Google的Maven存储库获得。 要使用它们，请按照下列步骤操作：

## 添加Google Maven repository

默认情况下，Android Studio项目未配置为访问此存储库。

要将其添加到项目中，请打开项目的build.gradle文件（而不是您的应用程序或模块的文件），并添加突出显示的行，如下所示：

	allprojects {
	    repositories {
	        jcenter()
	        maven { url 'https://maven.google.com' }
	    }
	}

<!-- more -->

## 添加Architecture Components
打开您的应用程序或模块的`build.gradle`文件，并将所需的组件添加为依赖关系：

- 使用Lifecycles, LiveData, 和 ViewModel添加：
	- compile "android.arch.lifecycle:runtime:1.0.0-alpha5"
	- compile "android.arch.lifecycle:extensions:1.0.0-alpha5"
	- annotationProcessor "android.arch.lifecycle:compiler:1.0.0-alpha5"
- 使用 Room，添加：
	- compile "android.arch.persistence.room:runtime:1.0.0-alpha5"
	- annotationProcessor "android.arch.persistence.room:compiler:1.0.0-alpha5"
	- 使用 testing Room migrations，添加：
		- testCompile "android.arch.persistence.room:testing:1.0.0-alpha5"
	- 使用  Room RxJava support，添加：
		- compile "android.arch.persistence.room:rxjava2:1.0.0-alpha5"


<hr>

下期[Android Architecture Components 详解(一)Handling Lifecycles](http://www.codepeng.cn/2017/08/11/Android%20Architecture%20Components%201/)