title: Gradle 如何自定义插件
tags:
  - gradle
categories:
  - Android
date: 2018-01-22 15:38:00

---
## 项目搭建步骤
 1. 新建一个Moudle
 2. 删除除了build.gradle 和 src 目录 以外所有文件
 3. src目录下新建main目录，main目录下新建groovy目录和resources目录
 4. 在groovy目录下新建项目包名
 5. resources目录下新建META-INF目录，META-INF目录下新建gradle-plugins目录
 
 项目的主题就已经搭建完成了。下面进行插件的开发
 
## 插件开发步骤
- 在moudle的buil.gardle文件中添加groovy插件和maven插件（上传至中央仓库使用）

	
	```
	apply plugin: 'groovy'
	apply plugin: 'maven'
	
	dependencies {
	    //gradle sdk
	    compile gradleApi()
	    //groovy sdk
	    compile localGroovy()
	}
	
	repositories {
	    mavenCentral()
	}
	
	```

-  在包下新建自定义插件的类`SimplePlugin.groovy`实现Plugin<T>接口，例如

	```
	class SimplePlugin implements Plugin<Project> {
    	void apply(Project project) {
        	project.task("simpleTask") << {
            println("my gradle plugin")
        }
    	}
	}
	```
	
- 在resources/META-INF/gradle-plugins目录下新建properties文件，com.test.plugin.properties,输入

	```
	implementation-class=com.test.plugin.SimplePlugin
	```
	

这样一个只会输出"my gradle plugin"的插件就完成了。接下来你可以发布到maven仓库上去了。