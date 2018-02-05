---
title: Hadoop集群环境搭建详细步骤
date: 2016-03-30 19:55:51
tags:
- 集群搭建
categories:
- Hadoop

---



## 一、准备工作

### 1、三台机器，配置hosts，并确保java环境jdk1.7.0_72
192.168.5.231   ubuntu231
192.168.5.232   ubuntu232
192.168.5.233   ubuntu233
### 2、ubuntu231选择作为主节点Master
下载hadoop-2.6.0安装包

<!-- more -->

## 二、解压

解压安装包到指定路径
这里的全路径是 /home/spark
## 三、ssh免密配置

```
$ ssh-keygen -t rsa
$ ssh-copy-id -i ~/.ssh/id_rsa.pub 要免密码的机器的IP 
```
## 四、环境变量配置

```
spark@ubuntu231:~$ vi .profile  
```

## 五、配置hadoop

在配置之前先在本地文件系统创建以下文件夹~/hadoop2.6.0/tmp、~/hadoop2.6.0/dfs/data、~/hadoop2.6.0/dfs/name
主要配置在hadoop-2.6.0/etc/hadoop目录下的七个文件

```
hadoop-env.sh
yarn-env.sh
slaves
core-site.xml
hdfs-site.xml
mapred-site.xml
yarn-site.xml
```

### 1、配置 hadoop-env.sh文件-->修改JAVA_HOME
```
export JAVA_HOME=/home/spark/jdk1.7.0_72
```
### 2、配置 yarn-env.sh 文件-->>修改JAVA_HOME
export JAVA_HOME=/home/spark/jdk1.7.0_72
### 3、配置slaves文件-->>增加slave节点
ubuntu232
ubuntu233
### 4、配置 core-site.xml文件-->>增加hadoop核心配置（hdfs文件端口是9000、file:/home/spark/hadoop-2.6.0/tmp）
```
<configuration>
 <property>
  <name>fs.defaultFS</name>
 <value>hdfs://192.168.5.231:9000</value>
 </property>
 <property>
  <name>io.file.buffer.size</name>
  <value>131072</value>
 </property>
 <property>
  <name>hadoop.tmp.dir</name>
  <value>file:/home/spark/hadoop-2.6.0/tmp</value>
  <description>Abasefor other temporary directories.</description>
 </property>
 <property>
  <name>hadoop.proxyuser.spark.hosts</name>
  <value>*</value>
 </property>
<property>
  <name>hadoop.proxyuser.spark.groups</name>
  <value>*</value>
 </property>
</configuration>
```
### 5、配置  hdfs-site.xml 文件-->>增加hdfs配置信息（namenode、datanode端口和目录位置）
```
<configuration>
 <property>
  <name>dfs.namenode.secondary.http-address</name>
  <value>192.168.5.231:9001</value>
 </property>
  <property>
   <name>dfs.namenode.name.dir</name>
   <value>file:/home/spark/hadoop-2.6.0/dfs/name</value>
 </property>
 <property>
  <name>dfs.datanode.data.dir</name>
  <value>file:/home/spark/hadoop-2.6.0/dfs/data</value>
  </property>
 <property>
  <name>dfs.replication</name>
  <value>3</value>
 </property>
<property>
  <name>dfs.webhdfs.enabled</name>
  <value>true</value>
 </property>
</configuration>
```
### 6、配置  mapred-site.xml 文件-->>增加mapreduce配置（使用yarn框架、jobhistory使用地址以及web地址）
```
<configuration>
  <property>
   <name>mapreduce.framework.name</name>
   <value>yarn</value>
 </property>
 <property>
  <name>mapreduce.jobhistory.address</name>
  <value>192.168.5.231:10020</value>
 </property>
 <property>
  <name>mapreduce.jobhistory.webapp.address</name>
  <value>192.168.5.231:19888</value>
 </property>
</configuration>
```
### 7、配置   yarn-site.xml  文件-->>增加yarn功能
```
<configuration>
  <property>
   <name>yarn.nodemanager.aux-services</name>
   <value>mapreduce_shuffle</value>
  </property>
  <property>
   <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
   <value>org.apache.hadoop.mapred.ShuffleHandler</value>
  </property>
  <property>
   <name>yarn.resourcemanager.address</name>
   <value>192.168.5.231:8032</value>
  </property>
  <property>
   <name>yarn.resourcemanager.scheduler.address</name>
   <value>192.168.5.231:8030</value>
  </property>
  <property>
   <name>yarn.resourcemanager.resource-tracker.address</name>
   <value>192.168.5.231:8035</value>
  </property>
  <property>
   <name>yarn.resourcemanager.admin.address</name>
   <value>192.168.5.231:8033</value>
  </property>
  <property>
   <name>yarn.resourcemanager.webapp.address</name>
   <value>192.168.5.231:8088</value>
  </property>
</configuration>
```
## 六、将配置好的hadoop文件copy到另外两台slave机器上（请保持目录一致）

```
scp -r hadoop-2.6.0/ spark@192.168.5.232:~/
scp -r hadoop-2.6.0/ spark@192.168.5.233:~/
```
 
## 七、格式化namenode

```
spark@ubuntu231:~$ cd hadoop-2.6.0/
spark@ubuntu231:~/hadoop-2.6.0$ ./bin/hdfs namenode -format
 
spark@ubuntu232:~$ cd hadoop-2.6.0/
spark@ubuntu232:~/hadoop-2.6.0$ ./bin/hdfs namenode -format
 
spark@ubuntu233:~$ cd hadoop-2.6.0/
spark@ubuntu233:~/hadoop-2.6.0$ ./bin/hdfs namenode -format
```
<hr>
到此我们的hadoop已经配置完成了