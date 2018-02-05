---
title: 文件权限以及chmod命令使用
date: 2017-02-13 20:12:45
tags:
- base
categories:
- base

---

在Linux系统或者OS X系统中我们对一个文件执行操作的时候经常会出现提示：

	Permission denied
	
意思是没有权限执行这个操作。
那首先我们看一下文件的权限

<!-- more -->

## 文件的权限

### 用户
有三种不同类型的用户可对文件或目录进行访问：文件所有者，同组用户、其他用户。所有者一般是文件的创建者。所有者可以允许同组用户有权访问文件，还可以将文件的访问权限赋予系统中的其他用户。在这种情况下，系统中每一位用户都能访问该用户拥有的文件或目录。

### 权限
每一文件或目录的访问权限都有三组，每组用三位表示，分别为文件属主的读、写和执行权限；与属主同组的用户的读、写和执行权限；系统中其他用户的读、写和执行权限。

我们使用ls -l命令可以查看当前目录下所有文件的详细信息。

	qiaopengdeMacBook-Air:python qiaopeng$ ls -l
	total 24
	-rwxr-xr-x  1 qiaopeng  staff  121  7 21 14:31 def.py
	-rwxr-xr-x  1 qiaopeng  staff   91  7 21 14:28 hanshu.py
	-rwxr-xr-x  1 qiaopeng  staff   67  7 18 17:24 helloworld.py
	
以def.py为例，

第一列共有10个位置，第一个字符指定了文件类型，在通常意义上，一个目录也是一个文件。如果第一个字符是横线，表示一个非目录的文件，如果是d，表示是一个目录。

从第二个字符开始到第十个字符一共9个字符，3个字符为一组，分别表示了三组用户对文件或者母的权限。权限字符用横线表示空许可。r代表只读，w代表写，x代表可执行。


例如：

	-rwxr-xr-x
	
表示def.py是一个普通文件，def.py的所有者有读写和执行的权限，与def.py所有者同组的用户有读和执行的权限，其他用户也有读和执行的权限。

## chmod命令使用

### 用法
	chmod [-cfvR] [--help] [--version] mode file...
	
### 参数说明
mode : 权限设定字串

file : 目标文件

其他参数说明：

- -c : 若该文件权限确实已经更改，才显示其更改动作
- -f : 若该文件权限无法被更改也不要显示错误讯息
- -v : 显示权限变更的详细资料
- -R : 对目前目录下的所有文件与子目录进行相同的权限变更(即以递回的方式逐个变更)
- --help : 显示辅助说明
- --version : 显示版本

### 文字设定法
	[ugoa...][[+-=][rwxX]...][,...]


其中：

- u 表示该文件的拥有者
- g 表示与该文件的拥有者属于同一个群体(group)者
- o 表示其他以外的人
- a 表示这三者皆是。
- \+ 表示增加权限、- 表示取消权限、= 表示唯一设定权限。
- r 表示可读取
- w 表示可写入
- x 表示可执行
- X 表示只有当该文件是个子目录或者该文件已经被设定过为可执行。

实例：

	chmod a+x def.py				
	
文件属主（u） 增加执行权限；与文件属主同组用户（g） 增加执行权限；其他用户（o） 增加执行权限。

### 八进制语法

chmod的八进制语法的数字说明：

	r 4
	w 2
	x 1
	- 0
- 权限用数字表达：权限位的数字加起来的总和。如rwx ，也就是4+2+1 ，应该是7。
rw- ，也就是4+2+0 ，应该是6。
r-x ，也就是4+0+1 ，应该是5。

例如修改文件def.py的权限:

	$ chmod 664 def.py
	$ ls -l
	$ -rw-rw-r--  1 qiaopeng  staff  121  7 21 14:31 def.py
#### 增加文件所有用户组可执行权限
	$ chmod a+x def.py
	$ ls -l
	$ -rwxrwxr-x  1 qiaopeng  staff  121  7 21 14:31 def.py
	
#### 删除文件权限
	$ chmod a-x def.py
	$ ls -l
	$ -rw-rw-r--  1 qiaopeng  staff  121  7 21 14:31 def.py
	
#### 同时修改不同用户权限
	$ chmod u+x,g-x,o+w def.py
	$ ls -l
	$ -rwxrw-rw-  1 qiaopeng  staff  121  7 21 14:31 def.py
	
#### 使用“=”设置权限 
	$ chmod u=r def.py
	$ ls -l
	$ -r--rw-rw-  1 qiaopeng  staff  121  7 21 14:31 def.py
给文件所有者（u）只设置可读权限。

#### -R参数使用
	$ chmod u+x myfile
	$ ls -l
	$ -r-xrw-rw-  1 qiaopeng  staff  121  7 21 14:31 def.py
	$ -r-xr-xr-x  1 qiaopeng  staff   91  7 21 14:28 hanshu.py
	$ -rwxr-xr-x  1 qiaopeng  staff   67  7 18 17:24 helloworld.py
给myfile目录下所有文件的文件所有者（u）增加可执行权限。
