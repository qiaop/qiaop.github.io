---
title: View动画之——Tween动画
date: 2017-01-18 11:53
tags: 
- Android动画
categories:
- Android

---
英文较好的可以移步[官方介绍](https://developer.android.com/guide/topics/graphics/view-animation.html)

**Tween动画（补间动画），可以在一个容器（布局）内执行透明度变化，旋转，大小变化，位移等动画，它是通过ParentView来不断调整ChildView的不同坐标来实现的。**

<!-- more-->

---
## Animation属性
package:android.view.animation;
抽象类 Animation;

|xml属性|	java方法|	解释|
|---|---|---|
|android:detachWallpaper|	setDetachWallpaper(boolean)|	是否在壁纸上运行|
|android:duration|	setDuration(long)|	动画持续时间，毫秒为单位|
|android:fillAfter|	setFillAfter(boolean)|	控件动画结束时是否保持动画最后的状态|
|android:fillBefore|	setFillBefore(boolean)|	控件动画结束时是否还原到开始动画前的状态|
|android:fillEnabled|	setFillEnabled(boolean)|	与android:fillBefore效果相同|
|android:interpolator|	setInterpolator(Interpolator)|	设定插值器（指定的动画效果，譬如回弹等）|
|android:repeatCount|	setRepeatCount(int)|	重复次数
|android:repeatMode|	setRepeatMode(int)|	重复类型有两个值，reverse表示倒序回放，restart表示从头播放|
|android:startOffset|	setStartOffset(long)|	调用start函数之后等待开始运行的时间，单位为毫秒|
|android:zAdjustment|	setZAdjustment(int)|	表示被设置动画的内容运行时在Z轴上的位置（top/bottom/normal），默认为normal|



---
## 抽象类 Animation的实现类
package:android.view.animation;

| Java类 | 动画 |
| ------   | -----  |
|AlphaAnimation|渐变透明度动画效果|
|RotateAnimation|画面转移旋转动画效果|
|ScaleAnimation|渐变尺寸伸缩动画效果|
|AnimationSet|动画容器|
|TranslateAnimation|画面转移位置移动动画效果|
Animation的实现类每一个都具有Animation的属性。

---
分别看一下每种动画的属性：

### Alpha属性
|xml属性|java方法| 	解释|
| ----- | ----- | ----- |
|android:fromAlpha|	AlphaAnimation(float fromAlpha, …)	|动画开始的透明度（0.0到1.0，0.0是全透明，1.0是不透明）
|android:toAlpha|	AlphaAnimation(…, float toAlpha)|	动画结束的透明度，同上|

### Rotate属性
|xml属性|	java方法|	解释|
|----|-------|------|
|android:fromDegrees|	RotateAnimation(float fromDegrees, …)|	旋转开始角度，正代表顺时针度数，负代表逆时针度数|
|android:toDegrees	|RotateAnimation(…, float toDegrees, …)|	旋转结束角度，正代表顺时针度数，负代表逆时针度数
|android:pivotX|	RotateAnimation(…, float pivotX, …)|	缩放起点X坐标（数值、百分数、百分数p，譬如50表示以当前View左上角坐标加50px为初始点、50%表示以当前View的左上角加上当前View宽高的50%做为初始点、50%p表示以当前View的左上角加上父控件宽高的50%做为初始点）|
|android:pivotY	|RotateAnimation(…, float pivotY)|	缩放起点Y坐标，同上规律|

### Scale属性
|xml属性|	java方法|	解释|
|---|---|---|
|android:fromXScale	|ScaleAnimation(float fromX, …)|	初始X轴缩放比例，1.0表示无变化|
|android:toXScale	|ScaleAnimation(…, float toX, …)|	结束X轴缩放比例|
|android:fromYScale	|ScaleAnimation(…, float fromY, …)|	初始Y轴缩放比例|
|android:toYScale	|ScaleAnimation(…, float toY, …)|	结束Y轴缩放比例|
|android:pivotX	|ScaleAnimation(…, float pivotX, …)|	缩放起点X轴坐标（数值、百分数、百分数p，譬如50表示以当前View左上角坐标加50px为初始点、50%表示以当前View的左上角加上当前View宽高的50%做为初始点、50%p表示以当前View的左上角加上父控件宽高的50%做为初始点）|
|android:pivotY	|ScaleAnimation(…, float pivotY)|	缩放起点Y轴坐标，同上规律|

### Translate属性
 |xml属性|	java方法|	解释|
 |---|---|----|
|android:fromXDelta|	TranslateAnimation(float fromXDelta, …)|	起始点X轴坐标（数值、百分数、百分数p，譬如50表示以当前View左上角坐标加50px为初始点、50%表示以当前View的左上角加上当前View宽高的50%做为初始点、50%p表示以当前View的左上角加上父控件宽高的50%做为初始点）|
|android:fromYDelta	|TranslateAnimation(…, float fromYDelta, …)|	起始点Y轴从标，同上规律|
|android:toXDelta|	TranslateAnimation(…, float toXDelta, …)|	结束点X轴坐标，同上规律|
|android:toYDelta|	TranslateAnimation(…, float toYDelta)|	结束点Y轴坐标，同上规律|
### AnimationSet属性
 动画容器，没有自己特有的属性，**继承自Animation的属性对标签下所有生效**。
 
## Tween动画使用方法



### Java代码方式
	
使用示例：
```
//Alpha动画

ImageView imageView = (ImageView) findViewById(R.id.imageView);

Animation animation = new AlphaAnimation(0.1f, 1.0f); //fromAlpha 0.1f   toAlpha 1.0f

animation.setDuration(1000);//动画持续时间

animation.setRepeatCount(-1);// 设置动画的重复次数，－1表示无限重复，0表示不重复

animation.setRepeatMode(Animation.REVERSE);// 设置动画重复时的切换模式（RESTART表示重新执行，REVERSE表示动画反操作）

imageView.startAnimation(animation);//开始动画

//imageView.setAnimation(animation);
//animation.start();
```
其余几种使用方式大同小异，不同的构造方法传不同的参数。

```
//AnimationSet使用

ImageView imageView = (ImageView) findViewById(R.id.imageView);
AnimationSet animationSet = new AnimationSet(true);

AlphaAnimation alphaAnimation = new AlphaAnimation(0.1f, 1.0f); //fromAlpha 0.1ftoAlpha 1.0f
alphaAnimation.setDuration(1000);

TranslateAnimation translateAnimation = new TranslateAnimation(0, 200, 0, 200);
translateAnimation.setDuration(1000);

animationSet.addAnimation(alphaAnimation);//添加Alpha动画
animationSet.addAnimation(translateAnimation);//添加Translate动画
imageView.startAnimation(animationSet);
```

### xml方式

在res/anim目录下新建资源文件

```
<?xml version="1.0" encoding="utf-8"?>
<alpha xmlns:android="http://schemas.android.com/apk/res/android"
    android:duration="3000"
    android:fromAlpha="1.0"
    android:toAlpha="0.0">
</alpha>
```
在要使用的地方：

```
ImageView imageView = (ImageView) findViewById(R.id.imageView);
Animation animation = AnimationUtils.loadAnimation(this,R.anim.alpha);
imageView.setAnimation(animation);
```
其他的类似。
### Interpolator插值器

```
public class
Interpolator
extends Object
```
Interpolator定义了动画变化的速率或规律
Interpolator接口的实现：
|java类|	xml id值|	描述|
|---|---|---|
|AccelerateDecelerateInterpolator|	@android:anim/accelerate_decelerate_interpolator	|动画始末速率较慢，中间加速
|AccelerateInterpolator|	@android:anim/accelerate_interpolator|	动画开始速率较慢，之后慢慢加速|
|AnticipateInterpolator|	@android:anim/anticipate_interpolator|	开始的时候从后向前甩|
|AnticipateOvershootInterpolator|	@android:anim/anticipate_overshoot_interpolator|	类似上面AnticipateInterpolator|
|BounceInterpolator|	@android:anim/bounce_interpolator|	动画结束时弹起|
|CycleInterpolator|	@android:anim/cycle_interpolator|	循环播放速率改变为正弦曲线|
|DecelerateInterpolator|	@android:anim/decelerate_interpolator|	动画开始快然后慢|
|LinearInterpolator|	@android:anim/linear_interpolator|	动画匀速改变|
|OvershootInterpolator|	@android:anim/overshoot_interpolator|	向前弹出一定值之后回到原来位置|
|PathInterpolator|		|新增，定义路径坐标后按照路径坐标来跑|
#### Interpolator使用
Java方式

```
AlphaAnimation alphaAnimation = new AlphaAnimation(0.1f, 1.0f); //fromAlpha 0.1f   toAlpha 1.0f
alphaAnimation.setDuration(1000);
alphaAnimation.setInterpolator(new AccelerateDecelerateInterpolator());

//AnimationSet
AnimationSet animationSet = new AnimationSet(true);
animationSet.setInterpolator(new AccelerateDecelerateInterpolator());
```
xml方式
```
<set xmlns:android="http://schemas.android.com/apk/res/android"
    android:interpolator="@android:anim/accelerate_decelerate_interpolator"
    android:shareInterpolator="true"
    android:fillAfter="true">
//也可以为单个动画设置
<alpha
    android:interpolator="@android:anim/anticipate_overshoot_interpolator"
    android:duration="3000"
    android:fromAlpha="1.0"
    android:toAlpha="0.0" />
```
### 动画监听
可以为每一个动画来注册一个监听，来监听动画的状态

```
AlphaAnimation alphaAnimation = new AlphaAnimation(0.1f, 1.0f); //fromAlpha 0.1f   toAlpha 1.0f
alphaAnimation.setDuration(1000);
alphaAnimation.setAnimationListener(new Animation.AnimationListener() {
	@Override
    public void onAnimationStart(Animation animation) {
	    //动画开始时
     }

	@Override
	public void onAnimationEnd(Animation animation) {
	    //动画重复时
	    }

	@Override
	public void onAnimationRepeat(Animation animation) {
	    //动画结束时
	    }
	});
```

## 自定义Tween动画
前面我们讲过View动画是通过ParentView来不断调整ChildView的不同坐标来实现的，动画的实现也就是通过变化像素矩阵的点来实现动画的，通过这个我们其实可以自己定制矩阵的变化来实现各种效果，像三维变换等。
在抽象类Animation中有一个重要的方法：

```
protected void applyTransformation(float interpolatedTime, Transformation t)
```
其实AlphaAnimation，RotateAnimation，ScaleAnimation|，TranslateAnimation都是通过定制这个方法来实现的。
系统通过不断调用这个方法来实现动画的变换，那我们要自己定制动画的话就通过定制 **Transformation t** 来告诉系统具体的变换方法。
**float interpolatedTime** 可以理解为动画的进度
在**Transformation**中有两个属性：

```
    protected Matrix mMatrix;//矩阵
    protected float mAlpha;//透明度
```

ok，实现一个抛物线的动画看看效果。

```
public class ParabolaAnimation extends Animation {

    private final float mPara;

    /**
     * Creates a new animation with a duration of 0ms, the default interpolator, with
     * fillBefore set to true and fillAfter set to false
     */
    public ParabolaAnimation(float mPara) {
        this.mPara = mPara;
    }

    /**
     * Initialize this animation with the dimensions of the object being
     * animated as well as the objects parents. (This is to support animation
     * sizes being specified relative to these dimensions.)
     * <p>
     * <p>Objects that interpret Animations should call this method when
     * the sizes of the object being animated and its parent are known, and
     * before calling {@link #getTransformation}.
     *
     * @param width        Width of the object being animated
     * @param height       Height of the object being animated
     * @param parentWidth  Width of the animated object's parent
     * @param parentHeight Height of the animated object's parent
     */
    @Override
    public void initialize(int width, int height, int parentWidth, int parentHeight) {
        super.initialize(width, height, parentWidth, parentHeight);
    }

    /**
     * Helper for getTransformation. Subclasses should implement this to apply
     * their transforms given an interpolation value.  Implementations of this
     * method should always replace the specified Transformation or document
     * they are doing otherwise.
     *
     * @param interpolatedTime The value of the normalized time (0.0 to 1.0)
     *                         after it has been run through the interpolation function.
     * @param t                The Transformation object to fill in with the current
     */
    @Override
    protected void applyTransformation(float interpolatedTime, Transformation t) {
        super.applyTransformation(interpolatedTime, t);

        float paraX = mPara * interpolatedTime;//横坐标随着时间匀速增加
        float paraY = paraX*paraX;//纵坐标为横坐标的平方
        final Matrix matrix = t.getMatrix();//拿到矩阵
        matrix.setTranslate(10*paraX,paraY);//调用矩阵的Translate方法
    }
}
```
使用：

```
final ImageView imageView = (ImageView) findViewById(R.id.imageView);
        imageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ParabolaAnimation parabolaAnimation = new ParabolaAnimation(imageView.getWidth());
                parabolaAnimation.setDuration(4000);
                imageView.startAnimation(parabolaAnimation);
            }
        });
```
看看效果：

![抛物线](http://img.blog.csdn.net/20160920154507307)

这只是一个简单的例子，更复杂一点的靠我们仔细去研究，但是方法都是差不多的。
<hr>
