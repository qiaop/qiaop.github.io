---
title: Spark集群搭建
date: 2016-03-31 19:35:45
tags:
- 集群搭建
categories:
- Hadoop

---



## 一、准备工作

### 1、三台机器，配置hosts，并确保java环境jdk1.7.0_72，scala环境scala-2.11.4

```
192.168.5.231   ubuntu231
192.168.5.232   ubuntu232
192.168.5.233   ubuntu233
```
### 2、ubuntu231选择作为主节点Master

下载spark-1.3.1-bin-hadoop2.6安装包

<!-- more -->

## 二、解压

解压安装包到指定路径
这里的全路径是 /home/spark
## 三、ssh免密配置（已经配置过就不用再配置）

```
$ ssh-keygen -t rsa
$ ssh-copy-id -i ~/.ssh/id_rsa.pub 要免密码的机器的IP
```
## 四、环境变量配置

```
spark@ubuntu231:~$ vi .profile 
export SCALA_HOME=/home/spark/scala-2.11.4
export SPARK_HOME=/home/spark/spark-1.3.1-bin-hadoop2.6
```
## 五、配置Spark

在spark-1.3.1-bin-hadoop2.6/conf目录下
### 1、配置 spark-env.sh
![](http://img.blog.csdn.net/20160330144709926?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
 
### 2、配置slaves

![](http://img.blog.csdn.net/20160330144806404?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

## 六、将配置好的hadoop文件copy到另外两台slave机器上（请保持目录一致）

```
scp -r spark-1.3.1-bin-hadoop2.6/ spark@192.168.5.232:~/
scp -r spark-1.3.1-bin-hadoop2.6/ spark@192.168.5.233:~/
```
到这里我们配置工作已经完成了
## 七、启动Spark集群

```
spark@ubuntu231:~/spark-1.3.1-bin-hadoop2.6$ cd sbin/
spark@ubuntu231:~/spark-1.3.1-bin-hadoop2.6/sbin$ ./start-all.sh 
```
## 八、通过webui查看集群状态

浏览器输入 http://192.168.5.231:8090/
![](http://img.blog.csdn.net/20160330144829943?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
