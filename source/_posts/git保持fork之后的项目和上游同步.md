---
title: git当原仓库更新后如何更新自己的fork
date: 2017-12-06 09:24:21
tags: git
categories: base

---


当fork了项目一段时间之后，发现上游仓库已经有了更新，那么这时候怎么让自己fork之后的仓库与上游仓库同步呢？

- **首先fork一个项目，在自己的账号下clone相应的仓库，然后使用命令：**
	`git remote -v`
	查看当前的远程仓库地址。输出：
	![](/images/post/git/git_fork.png)
<!-- more -->		

- **添加一个别名为 upstream 的上游仓库的地址，使用命令：**
	```
	git remote add upstream git@github.com:spardon/flask_web_develope.git
	```
	然后再执行命令`git remote -v`，输出如下：
	![](/images/post/git/git_fork_1.png)	
- **最后执行以下命令：**

	```
	#从上游仓库获取到分支，及相关的提交信息
	git fetch upstream 
	
	#切换本地仓库到master分支
	git checkout master
	
	#合并上游仓库的master分支
	git merge upstream/master
	
	#将内容更改push到自己fork的远程仓库
	git push origin master
	```
	
当然也可以在页面上操作。