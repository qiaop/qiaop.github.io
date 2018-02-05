---
title: 基于virtualenvs安装TensorFlow
date: 2017-06-02 16:57:45
tags:
- 安装
categories:
- TensorFlow

---
## 前提

- 使用Mac OS X系统
- 系统的Python环境是2.7的，使用homebrew安装了Python3
- 安装了 virtualenv来统一管理环境

<!-- more -->

## 创建环境

```
qiaopengdeMacBook-Air:~ qiaopeng$ virtualenv -p /usr/local/bin/python3 tensorflow

qiaopengdeMacBook-Air:~ qiaopeng$ source tensorflow/bin/activate

```
## 安装TensorFlow

```
(tensorflow) qiaopengdeMacBook-Air:~ qiaopeng$ sudo pip3 install --upgrade https://storage.googleapis.com/tensorflow/mac/tensorflow-0.8.0-py3-none-any.whl

```

稍等一会，安装成功

## 测试

```
(tensorflow) qiaopengdeMacBook-Air:~ qiaopeng$ python
Python 3.6.1 (default, Apr  4 2017, 09:40:21) 
[GCC 4.2.1 Compatible Apple LLVM 8.1.0 (clang-802.0.38)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow as tf
>>> hello = tf.constant('Hello, TensorFlow')
>>> sess = tf.Session()
>>> print(sess.run(hello))
b'Hello, TensorFlow'
>>> a = tf.constant(10)
>>> b = tf.constant(32)
>>> print(sess.run(a + b))
42
>>> print(sess.run(a * b))
320

```
