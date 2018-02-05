---
title: Mac OS X上安装TensorFlow
date: 2017-07-24 17:31:28
tags:
- 安装
- Mac OS X
- 翻译
categories:
- TensorFlow

---

[原文链接](https://www.tensorflow.org/install/install_mac)

本指南介绍如何在Mac OS X上安装TensorFlow。

## 确定如何安装TensorFlow
您必须选择安装TensorFlow的机制。 支持的选择如下：

- virtualenv
- "native" pip
- Docker
- 从源码安装

**我们建议利用virtualenc安装。**[Virtualenv](https://virtualenv.pypa.io/en/stable/)
是与其他Python开发隔离的虚拟Python环境，不会干扰或受到同一台机器上其他Python程序的影响。 在virtualenv安装过程中，您将不仅安装TensorFlow，还可以安装TensorFlow所需的所有软件包。 （这实际上很简单。）要开始使用TensorFlow，只需要“激活”虚拟环境。 总而言之，virtualenv为安装和运行TensorFlow提供了一个安全可靠的机制。

<!-- more -->

Native pip直接在您的系统上安装TensorFlow，而不需要通过任何容器或虚拟环境系统。 由于Native pip安装不被打断，点安装可能会干扰或受到系统上其他基于Python的安装的影响。 此外，您可能需要禁用系统完整性保护（SIP）才能通过Native pip安装。 但是，如果您了解SIP，pip和您的Python环境，则Native pip安装相对容易执行。

[Docker](http://docker.com/)将TensorFlow安装与机器上预先存在的包完全隔离。 Docker容器包含TensorFlow及其所有依赖项。 请注意，Docker镜像可能相当大（数百MB）。 如果您将TensorFlow集成到已经使用Docker的较大应用程序架构中，则可以选择Docker安装。

在Anaconda中，您可以使用conda创建虚拟环境。 但是，在Anaconda中，我们建议您使用pip install命令安装TensorFlow，而不是使用conda install命令。

**注意：**conda package是社区支持的，没有正式支持。 也就是说，TensorFlow团队既不测试也不维护conda package。 使用该包，您自己承担风险。

## Installing with virtualenv
按照以下步骤安装TensFlow与Virtualenv：

1. 启动一个终端（一个shell）。 您将在此shell中执行所有后续步骤。
2. 通过以下命令安装pip和virtualenv：

		$ sudo easy_install pip
 		$ sudo pip install --upgrade virtualenv 

3. 通过下面其中一个命令来创建一个virtualenv环境：

		$ virtualenv --system-site-packages targetDirectory # for Python 2.7
 		$ virtualenv --system-site-packages -p python3 targetDirectory # for Python 3.n
 		
 目标目录标识virtualenv目录的顶部。 我们的说明假定目标目录为`〜/ tensorflow`，但您可以选择任何目录。
 
4. 通过以下命令之一激活virtualenv环境：

		$ source ~/tensorflow/bin/activate      # If using bash, sh, ksh, or zsh
		$ source ~/tensorflow/bin/activate.csh  # If using csh or tcsh 
		
 前面的source命令应该将您的提示更改为以下内容：

		(tensorflow)$ 
		
5. 如果系统上安装了pip版本8.1或更高版本，请用以下命令之一以将TensorFlow和TensorFlow所需的所有软件包安装到活动的Virtualenv环境中：
		
		$ pip install --upgrade tensorflow      # for Python 2.7
 		$ pip3 install --upgrade tensorflow     # for Python 3.n

		If the preceding command succeed, skip Step 6. If it failed,perform Step 6.
6. 可选。 如果步骤5失败（通常是因为您调用低于8.1的pip版本），请通过以下格式的命令在激活的virtualenv环境中安装TensorFlow：

		$ pip install --upgrade tfBinaryURL   # Python 2.7
 		$ pip3 install --upgrade tfBinaryURL  # Python 3.n 
 		
 其中tfBinaryURL标识TensorFlow Python包的URL。 tfBinaryURL的值取决于操作系统和Python版本。 在这里找到适合您系统的tfBinaryURL的值。 例如，如果要安装适用于Mac OS X的TensorFlow（Python 2.7），则在活动的Virtualenv中安装TensorFlow的命令如下所示：
 
 		$ pip3 install --upgrade \https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.2.1-py2-none-any.whl
 		
 如果遇到安装问题，请参阅常见安装问题。
 
### 下一步
安装TensorFlow后，验证您的安装以确认安装是否正常工作。

请注意，每次在新的shell中使用TensorFlow时，必须激活virtualenv环境。 如果virtualenv环境当前未处于活动状态（即，提示符不是（tensorflow）），则调用以下命令之一：
		
	$ source ~/tensorflow/bin/activate      # bash, sh, ksh, or zsh
	$ source ~/tensorflow/bin/activate.csh  # csh or tcsh 
	
您的提示将转换为以下内容，表示您的tensorflow环境处于活动状态：

	(tensorflow)$ 
	
当virtualenv环境处于活动状态时，您可以从此shell运行TensorFlow程序。

使用TensorFlow完成后，您可以通过发出以下命令来停用环境：

	(tensorflow)$ deactivate 
	
提示将恢复为默认提示符（由PS1定义）。

### Uninstalling TensorFlow
如果要卸载TensorFlow，只需删除您创建的目录。 例如：

	$ rm -r ~/tensorflow 
	
## Installing with native pip

我们已将TensorFlow二进制文件上传到PyPI。 因此，您可以通过pip安装TensorFlow。

 [REQUIRED_PACKAGES section of setup.py](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/pip_package/setup.py)列出了pip将安装或升级的软件包。
### 先决条件：Python
要安装TensorFlow，您的系统必须包含以下Python版本之一：

- Python2.7
- Python3.3+

如果您的系统尚未具有以前的一个Python版本，请[立即安装](https://wiki.python.org/moin/BeginnersGuide/Download)。

安装Python时，您可能需要禁用系统完整性保护（SIP），以允许Mac App Store以外的其他实体安装软件。
### 先决条件：pip
[Pip](https://en.wikipedia.org/wiki/Pip_(package_manager))安装和管理用Python编写的软件包。 如果您打算使用native pip安装，则必须在系统上安装以下之一：

- `pip`, for Python 2.7
- `pip3`, for Python 3.n.

当您安装Python时pip或pip3可能一起安装在您的系统上。 要确定pip或pip3是否实际安装在系统上，请执行以下命令之一：

	$ pip -V  # for Python 2.7
	$ pip3 -V # for Python 3.n 
	
我们强烈建议您使用pip或pip3版本8.1或更高版本，以安装TensorFlow。 如果未安装pip或pip3 8.1或更高版本，请执行以下命令进行安装或升级：

	$ sudo easy_install --upgrade pip
	$ sudo easy_install --upgrade six 
	
### Install TensorFlow
假设您的Mac上安装了必备软件，请执行以下步骤：

1. 通过执行以下命令之一安装TensorFlow：

		$ pip install tensorflow      # Python 2.7; CPU support
 		$ pip3 install tensorflow     # Python 3.n; CPU support

		If the preceding command runs to completion, you should now validate your installation.

2. （可选）如果步骤1失败，请通过执行以下格式的命令安装最新版本的TensorFlow：

		$ sudo pip  install --upgrade tfBinaryURL   # Python 2.7
 		$ sudo pip3 install --upgrade tfBinaryURL   # Python 3.n 
 		
 其中tfBinaryURL标识TensorFlow Python包的URL。 tfBinaryURL的适当值取决于操作系统和Python版本。 在这里找到适合tfBinaryURL的值。 例如，如果要安装TensorFlow for Mac OS和Python 2.7，请执行以下命令：

 		$ sudo pip3 install --upgrade \
 		https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.2.1-py2-none-any.whl 
 
 如果上述命令失败，请参见安装问题。
 
### 下一步
安装TensorFlow后，验证您的安装以确认安装是否正常工作。
### Uninstalling TensorFlow

要卸载TensorFlow，请发出以下命令之一：

	$ pip uninstall tensorflow
	$ pip3 uninstall tensorflow 

## Installing with Docker
按照以下步骤通过Docker安装TensorFlow。

1. 在[Docker](https://docs.docker.com/engine/installation/#/on-macos-and-windows)文档中所述安装Docker。
2. 启动包含TensorFlow二进制映像的Docker容器。

本节的其余部分将介绍如何启动Docker容器。

要启动保存TensorFlow二进制映像的Docker容器，请输入以下格式的命令：

	$ docker run -it -p hostPort:containerPort TensorFlowImage 

**where:**

- -p hostPort：containerPort是可选的。 如果要从shell运行TensorFlow程序，请忽略此选项。 如果要从Jupyter notebook运行TensorFlow程序，请将hostPort和containerPort设置为8888.如果要在容器内运行TensorBoard，请添加第二个-p标志，将hostPort和containerPort设置为6006。
- 需要TensorFlowImage。 它标识了Docker容器。 您必须指定以下值之一：
    - `gcr.io/tensorflow/tensorflow`: TensorFlow二进制镜像。
    - gcr.io/tensorflow/tensorflow:latest-devel：TensorFlow二进制镜像加源代码。
    
`gcr.io`是Google容器注册表。 请注意，dockerhub还提供了一些TensorFlow镜像。

例如，以下命令在Docker容器中启动TensorFlow CPU二进制映像，您可以在其中运行Shell中的TensorFlow程序：

	$ docker run -it gcr.io/tensorflow/tensorflow bash
	
以下命令还在Docker容器中启动TensorFlow CPU二进制映像。 并且，在这个Docker容器中，您可以在Jupyter notebook中运行TensorFlow程序：

	$ docker run -it -p 8888:8888 gcr.io/tensorflow/tensorflow
	
Docker将在第一次启动的时候下载TensorFlow二进制映像。
### 下一步
安装TensorFlow后，验证您的安装以确认安装是否正常工作。

## Installing with Anaconda
Anaconda安装是社区支持的，没有正式支持。

采取以下步骤在Anaconda环境中安装TensorFlow：

1. 按照[Anaconda下载](https://www.continuum.io/downloads)网站上的说明下载并安装Anaconda。
2. 执行以下命令创建一个名为`tensorflow`的conda环境：

	$ conda create -n tensorflow
	
3. 执行以下命令激活conda环境：

		$ source activate tensorflow
 		(tensorflow)$  # Your prompt should change
 		
4. 执行以下命令，以在您的conda环境中安装TensorFlow：

		(tensorflow)$ pip install --ignore-installed --upgrade TF_PYTHON_URL
		
其中TF_PYTHON_URL是TensorFlow Python包的URL。 例如，以下命令将安装仅适用于Python 2.7的仅限于CPU的版本的TensorFlow：

	(tensorflow)$ pip install --ignore-installed --upgrade \
 	https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.2.1-py2-none-any.whl
 	
## 验证您的安装
要验证您的TensorFlow安装，请执行以下操作：

1. 确保您的环境准备运行TensorFlow程序。
2. 运行一个简短的TensorFlow程序。

### 准备你的环境
如果您安装在native pip，virtualenv或Anaconda上，请执行以下操作：

1. 启动一个终端。
2. 如果您安装了virtualenv或Anaconda，请激活您的容器。
3. 如果您安装了TensorFlow源代码，请导航到除TensorFlow源代码之外的任何目录。

如果您通过Docker安装，请启动运行bash的Docker容器。 例如：

	$ docker run -it gcr.io/tensorflow/tensorflow bash
	

### 运行一个简短的TensorFlow程序
从你的shell调用python如下：

	$ python
	
在python交互式shell中输入以下短程序：

```
# Python
import tensorflow as tf
hello = tf.constant('Hello, TensorFlow!')
sess = tf.Session()
print(sess.run(hello))

```
如果系统输出以下内容，则可以开始编写TensorFlow程序：

	Hello, TensorFlow!
	
如果您是TensorFlow的新手，请参阅[TensorFlow入门](https://www.tensorflow.org/get_started/get_started)。

如果系统输出错误信息而不是问候，请参阅常见的安装问题。

## 常见的安装问题
我们依靠Stack Overflow来记录TensorFlow安装问题及其补救措施。 下表包含一些常见安装问题的Stack Overflow答案的链接。 如果您遇到下表中未列出的错误消息或其他安装问题，请在Stack Overflow中进行搜索。 如果Stack Overflow没有显示错误消息，请在Stack Overflow上询问一个有关它的新问题，并指定`tensorflow`标签。

Stack Overflow 链接|错误信息
---|---
[42006320](http://stackoverflow.com/q/42006320)|ImportError: Traceback (most recent call last):<br>File ".../tensorflow/core/framework/graph_pb2.py", line 6, in from google.protobuf import descriptor as \_descriptor<br>ImportError: cannot import name 'descriptor'
[33623453](https://stackoverflow.com/q/33623453)|IOError: [Errno 2] No such file or directory:'/tmp/pip-o6Tpui-build/setup.py'
[35190574](https://stackoverflow.com/questions/35190574)|SSLError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed
[42009190](http://stackoverflow.com/q/42009190)|Installing collected packages:setuptools, protobuf, wheel, numpy, tensorflow Found existing installation:<br> setuptools 1.1.6 <br>Uninstalling setuptools-1.1.6: <br> Exception:<br> ... <br>[Errno 1] Operation not permitted: '/tmp/pip-a1DXRT-uninstall/.../lib/python/_markerlib' 
[33622019](https://stackoverflow.com/q/33622019)|ImportError: No module named copyreg
[37810228](http://stackoverflow.com/q/37810228)|During a pip install operation, the system returns:<br>OSError: [Errno 1] Operation not permitted
[33622842](http://stackoverflow.com/q/33622842)|An import tensorflow statement triggers an error such as the following:<br>Traceback (most recent call last):<br>File "", line 1, in<bar>File "/usr/local/lib/python2.7/site-packages/tensorflow/\_\_init\_\_.py",<br>line 4, in from tensorflow.python import *<br>...<br>File "/usr/local/lib/python2.7/site-packages/tensorflow/core/framework/tensor_shape_pb2.py",line 22, in serialized_pb=_b('\n,tensorflow/core/framework/tensor_shape.proto\x12\ntensorflow\"d\n\x10TensorShapeProto\x12-\n\x03\x64im\x18\x02\x03(\x0b\x32.tensorflow.TensorShapeProto.Dim\x1a!\n\x03\x44im\x12\x0c\n\x04size\x18\x01\x01(\x03\x12\x0c\n\x04name\x18\x02 \x01(\tb\x06proto3')<br>TypeError: \_\_init__() got an unexpected keyword argument 'syntax'
[42075397](http://stackoverflow.com/q/42075397)|A pip install command triggers the following error:<br>...<br>You have not agreed to the Xcode license agreements, please run'xcodebuild -license' (for user-level acceptance) or 'sudo xcodebuild -license' (for system-wide acceptance) from within a Terminal window to review and agree to the Xcode license agreements.<br>...<br>File "numpy/core/setup.py", line 653, in get_mathlib_info<br><br>raise RuntimeError("Broken toolchain: cannot link a simple C program")<br><br>RuntimeError: Broken toolchain: cannot link a simple C program

## The URL of the TensorFlow Python package
一些安装机制需要TensorFlow Python包的URL。 您指定的值取决于三个因素：

- 操作系统
- Python版本

本节介绍Mac OS安装的相关值。
### Python 2.7

	https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.2.1-py2-none-any.whl

### Python 3.4, 3.5, or 3.6

	https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.2.1-py3-none-any.whl
	
## Protobuf pip package 3.1
您可以跳过此部分，除非您看到与protobuf pip软件包相关的问题。

**注意：**如果您的TensorFlow程序运行缓慢，您可能会遇到与protobuf pip软件包相关的问题。

TensorFlow pip软件包取决于protobuf pip软件包版本3.1。 从PyPI下载的protobuf pip软件包（在调用pip install protobuf时）是一个仅包含Python的库，其中包含可执行比C ++实现慢10倍 - 50倍的原始序列化/反序列化的Python实现。 Protobuf还支持包含基于快速C ++的原语解析的Python包的二进制扩展。 此扩展在标准的仅Python专用pip包中不可用。 我们为protobuf创建了一个包含二进制扩展名的自定义二进制pip包。 要安装自定义二进制protobuf pip包，请调用以下命令之一：

- for Python 2.7:

		$ pip install --upgrade \
		https://storage.googleapis.com/tensorflow/mac/cpu/protobuf-3.1.0-cp27-none-macosx_10_11_x86_64.whl
		
- for Python 3.n:

		$ pip3 install --upgrade \
		https://storage.googleapis.com/tensorflow/mac/cpu/protobuf-3.1.0-cp35-none-macosx_10_11_x86_64.whl
		
安装此protobuf软件包将覆盖现有的protobuf软件包。 请注意，binary pip软件包已经支持大于64MB的protobufs，应该修复以下错误：

	[libprotobuf ERROR google/protobuf/src/google/protobuf/io/coded_stream.cc:207]
	A protocol message was rejected because it was too big (more than 67108864 bytes).
	To increase the limit (or to disable these warnings), see
	CodedInputStream::SetTotalBytesLimit() in google/protobuf/io/coded_stream.h.