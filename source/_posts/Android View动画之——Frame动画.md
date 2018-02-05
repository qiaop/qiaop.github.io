---
title: View动画之——Frame动画
date: 2017-01-18 11:54
tags: 
- Android动画
categories:
- Android

---

Drawable Animation,Drawable动画也叫Frame动画，是加载一系列的drawable资源然后逐帧地显示出来的动画，就像放幻灯片一样，其实Drawable Animation也属于View Animation。

<!-- more -->

## Frame Animation使用
Frame Animation也可以使用Java代码方式和xml两种方式，但是推荐使用xml方式。
### xml方式
首先在资源文件res/drawable目录下新建一个文件，例如 drawable_animation.xml

```
<?xml version="1.0" encoding="utf-8"?>
<animation-list xmlns:android="http://schemas.android.com/apk/res/android"
    android:oneshot="false"
    android:variablePadding="false">
    <item
        android:drawable="@drawable/f0"
        android:duration="100" />
    <item
        android:drawable="@drawable/f1"
        android:duration="100" />
    <item
        android:drawable="@drawable/f2"
        android:duration="100" />
    <item
        android:drawable="@drawable/f3"
        android:duration="100" />
    <item
        android:drawable="@drawable/f4"
        android:duration="100" />

</animation-list>
```
以**animation-list**为根元素，以**item**表示要轮换显示的图片，**duration**属性表示各项显示的时间。
**android:oneshot="false"** 是循环播放，为**true**的话则播放到最后一张图片就会停止播放；
**android:variablePadding="false"**此属性的意思是padding是否随着Drawable的变化而变化，默认值是false，不建议开启此选项。

播放动画

```
    ImageView imageView;
    AnimationDrawable animationDrawable;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        imageView = (ImageView) findViewById(R.id.imageView);
        imageView.setBackgroundResource(R.drawable.drawable_animation);
        animationDrawable = (AnimationDrawable) imageView.getBackground();
        imageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                animationDrawable.start();
            }
        });
    }
```

**注意**
最好不要在**onCreate()**方法里开始动画， 因为AnimationDrawable 可能还没有完全附着在Window上，如果你要马上执行动画可以在 **onWindowFocusChanged()**里开始动画。

### Java代码方式

```
        imageView = (ImageView) findViewById(R.id.imageView);
        animationDrawable = new AnimationDrawable();
        Drawable drawable1 = getResources().getDrawable(R.drawable.f0);
        Drawable drawable2 = getResources().getDrawable(R.drawable.f1);
        Drawable drawable3 = getResources().getDrawable(R.drawable.f2);
        Drawable drawable4 = getResources().getDrawable(R.drawable.f3);
        Drawable drawable5 = getResources().getDrawable(R.drawable.f4);
        animationDrawable.addFrame(drawable1,100);
        animationDrawable.addFrame(drawable2,100);
        animationDrawable.addFrame(drawable3,100);
        animationDrawable.addFrame(drawable4,100);
        animationDrawable.addFrame(drawable5,100);
        imageView.setBackgroundDrawable(animationDrawable);
        animationDrawable.start();
```
看看效果：
![drawable动画](http://img.blog.csdn.net/20160921161733248)
这个人好像没穿衣服