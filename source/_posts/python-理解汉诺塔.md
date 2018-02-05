---
title: python 理解汉诺塔
date: 2017-07-27 14:20:15
tags:
- base
categories:
- python

---
## 代码实现

汉诺塔是python中函数递归的一个使用。

```
def move(n,a,b,c):
    if n==1:
        print(a,'->',c)
    else:
        move(n-1,a,c,b)
        move(1,a,b,c)
        move(n-1,b,a,c)
move(3,'A','B','C')

```
## 理解
>move(N,起点，缓冲区，终点）

>N: 盘子的个数。

**汉诺塔永远只有三步**：

<!--more-->

把n个盘子抽象成两个盘子，n-1 和 底下最大的1:

>n = (n-1) + 1

### 第一步

把n-1移到缓冲区

### 第二步
把1移到终点

### 第三步
把缓冲区的n-1 移到 终点

每一步的实现都是通过递归move函数来进行。