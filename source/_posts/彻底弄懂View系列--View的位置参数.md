---
title: 彻底弄懂View系列--View的位置参数
date: 2016-03-03 17:01:51
tags:
- Android
- View基础知识
categories:
- Android

---


![View的位置参数](http://img.blog.csdn.net/20161031160030873)

<!-- more -->

View的这几个参数都是相对于View的父容器来说的。

- top是左上角纵坐标，获取方式Top= getTop();
- left是左上角横坐标。获取方式Left= getLeft();
- bottom是右下角纵坐标。获取方式Bottom= getBottom;
- right是右下角横坐标。获取方式Right= getRight();

因此View的宽高：

```java 
width = right - left;
height = bottom - top;
```

Android3.0开始，View增加了几个参数x、y、translationX和translationY。x和y是View左上角的坐标，而translationX和translationY是View左上角相对于父容器的偏移量。这几个参数也是相对于父容器。
translationX和translationY的默认值是0。

**注意**
View在平移过程中，top和left表示的是原始左上角的位置信息，其值并不会发生改变，此时改变的是x、y、translationX和translationY这四个参数。

```
x = left + translationX;
y = top + translationY;
```
**扩展知识**

在MotionEvent中系统提供了两组方法getX/getY和getRawX/getRawY。getX/getY返回的是点击位置相对于当前View左上角的x和y坐标，getRawX/getRawY返回的是点击位置相对于手机屏幕左上角的x和y坐标。