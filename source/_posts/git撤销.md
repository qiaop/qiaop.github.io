---
title: git撤销
date: 2017-10-19 15:08:47
tags: git
categories:
- base

---
## git撤销
### 撤销工作区更改

	git checkout --filename
	
### 撤销add
	git reset HEAD .//撤销全部
	git reset HEAD filename
	
### 撤销commit
	git reset --hard commit_id 