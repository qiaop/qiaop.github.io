---
title: Android属性动画（二）——ValueAnimator
date: 2017-01-17 15:32:51
tags:
- android
- csdn
categories:
- Android

---
前面我们了解了比较常用的ObjectAnimator，它继承自ValueAnimator，这篇我们研究属性动画最核心的一个类ValueAnimator。
属性动画的实现机制是通过对目标对象进行赋值并修改其属性来实现的，而初始值和结束值之间的平滑的过渡就是ValueAnimator来实现的。

<!-- more -->

我们先来看看ValueAnimator怎么使用

## ValueAnimator使用
ValueAnimator的使用方法非常简单，跟ObjectAnimator类似。

```
ValueAnimator animator = ValueAnimator.ofFloat(0f,1f);
animator.setDuration(3000).start();
```
![方法](http://img.blog.csdn.net/20160927101029556)

这是ValueAnimator 提供的方法，ofArgb是API21新添加的。使用方法都类似，PropertyValuesHolder我们上一篇文章已经介绍过了。
上面一段代码是将0f平滑过渡到1f，但是我们看不到效果，怎么知道它平滑过度了呢？添加监听。

```
ValueAnimator animator = ValueAnimator.ofFloat(0f,1f);
animator.setDuration(3000);
animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
	@Override
	public void onAnimationUpdate(ValueAnimator animation) {
		float value = (float) animation.getAnimatedValue();
		Log.e("TAG", "the animation value is " + value);
	}
);
animator.start();
```
在日志上我们看到这个值3s内平滑过渡了，到这里我想你已经明白了怎么去实现动画了。

```
ValueAnimator animator = ValueAnimator.ofFloat(0f, 1f);
animator.setDuration(3000);
animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
	@Override
	public void onAnimationUpdate(ValueAnimator animation) {
		float value = (float) animation.getAnimatedValue();
		textView.setAlpha(value);
	}
});
animator.start();
```
看看效果
![ValueAnimator](http://img.blog.csdn.net/20160927104631580)

也就是说我们可以在**onAnimationUpdate** 这个监听里去做属性值的改变，相对于ObjectAnimator的用法，ValueAnimator更加灵活，不需要操作的对象属性一定要有set和get方法，可以根据当前动画的计算值来操作任何属性。
我们来看一个例子，还是一样用上一篇文章中我们自定义的PointView，看看ValueAnimator怎么实现动画。

```
ValueAnimator animator = ValueAnimator.ofFloat( 100f, 500f, 100f);
animator.setDuration(2000);
animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
	@Override
	public void onAnimationUpdate(ValueAnimator animation) {
		float value = (float) animation.getAnimatedValue();
		pointView.setPointRadius(value);//设置半径属性值
		pointView.setAlpha(1f-value*0.002f);//设置透明度
		}
	});
animator.start();
```
看看效果
![ValueAnimator](http://img.blog.csdn.net/20160927140600185)

我们可以实现同样的效果，而且更灵活改变它的透明度等等。
