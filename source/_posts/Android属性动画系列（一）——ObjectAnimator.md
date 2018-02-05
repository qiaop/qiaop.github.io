---
title: Android属性动画系列（一）——ObjectAnimator
date: 2017-01-17 12:48
tags:
- android
categories:
- Android

---
Property Animation（属性动画）是Android3.0引入的动画系统，功能非常强大几乎完全可以取代Tween 动画（补间动画），而且弥补了Tween动画的缺陷。它可以设置给任何Object，包括那些还没有渲染到屏幕上的对象。这种动画是可扩展的，可以让你自定义任何类型和属性的动画。

<!-- more -->

**属性动画的实现机制是通过对目标对象进行赋值并修改其属性来实现的。**
#ObjectAnimator
ObjectAnimator继承自ValueAnimator（后面再讲），ObjectAnimator可能是属性动画中最常用最实用的一个类，常用的方法有：ofFloat()，ofInt()，ofObject()，ofArgb()，ofPropertyValuesHolder()。
##ObjectAnimator基本使用方法

```
 //平移
ObjectAnimator translatAnimator = ObjectAnimator.ofFloat(textView, "translationX", 0f, 200f, 0f);
translatAnimator.setDuration(3000).start();
```

```
//旋转
ObjectAnimator rotationAnimator = ObjectAnimator.ofFloat(textView, "rotationY", 0f, 90f, 360f);
rotationAnimator.setDuration(3000).start();
```

```
 //缩放
ObjectAnimator scaleAnimator = ObjectAnimator.ofFloat(textView, "scaleY", 1f, 0f, 1f);
scaleAnimator.setDuration(3000).start();
```

```
//透明度
ObjectAnimator alphaAnimator = ObjectAnimator.ofFloat(textView, "alpha", 1.0f, 0f, 1f);
alphaAnimator.setDuration(3000).start();
```

![ObjectAnimator](http://img.blog.csdn.net/20160926140429333)

这里的几个参数

```
public static ObjectAnimator ofFloat(Object target, String propertyName, float... values) {
        ObjectAnimator anim = new ObjectAnimator(target, propertyName);
        anim.setFloatValues(values);
        return anim;
    }
```
- 第一个参数是目标对象，就是要把动画设置给谁。
- 第二个参数是有get和set方法的属性名，ObjectAnimator 改变对象的属性值就是通过get和set方法改变的。
- 第三个参数是动画过渡值，可以是n个。

另外，ObjectAnimator提供了下面的方法来配置动画

```
setInterpolator()：设置动画插值
setDuration()：设置动画执行时间
setRepeatCount()：设置动画重复次数
setRepeatMode()：设置动画重复模式
setStartDelay():设置动画延时操作
setTarget():设置动画的对象
setEvaluator()：设置动画过度的评估者。
```

## 实现一个组合动画
要想动画效果复杂一点，就需要组合几种动画，常用的有两种方式组合动画。
### AnimatorSet

```
AnimatorSet animatorSet = new AnimatorSet();
ObjectAnimator animator1 = ObjectAnimator.ofFloat(textView, "translationY", 0f, 300f，0f);
ObjectAnimator animator2 = ObjectAnimator.ofFloat(textView, "scaleX", 1f, 3f);
ObjectAnimator animator3 = ObjectAnimator.ofFloat(textView, "rotation", 0f, 720f);
ObjectAnimator animator4 = ObjectAnimator.ofFloat(textView, "alpha", 1f, 0f，1f);
animatorSet.play(animator3).with(animator4).after(animator1).after(animator2);
animatorSet.setDuration(5000);
animatorSet.start();
```
![AnimatorSet](http://img.blog.csdn.net/20160926143353898)

AnimatorSet提供了一个play()方法，向这个方法中传入一个Animator对象(ValueAnimator或ObjectAnimator)会返回一个AnimatorSet.Builder的实例，AnimatorSet.Builder中包括以下四个方法：

```
after(Animator anim) 将现有动画插入到传入的动画之后执行 
after(long delay) 将现有动画延迟指定毫秒后执行 
before(Animator anim) 将现有动画插入到传入的动画之前执行 
with(Animator anim) 将现有动画和传入的动画同时执行
```
### PropertyValuesHolder
PropertyValuesHolder也可是实现组合动画，但是只能多个动画一起执行。

```
PropertyValuesHolder valuesHolder1 = PropertyValuesHolder.ofFloat("translationX", 0f, 200f, 0f);
PropertyValuesHolder valuesHolder2 = PropertyValuesHolder.ofFloat("rotationY", 0f, 90f, 360f);
PropertyValuesHolder valuesHolder3 = PropertyValuesHolder.ofFloat("scaleY", 1f, 0f, 1f);
PropertyValuesHolder valuesHolder4 = PropertyValuesHolder.ofFloat("alpha", 1.0f, 0f, 1f);

ObjectAnimator objectAnimator = ObjectAnimator.ofPropertyValuesHolder(textView,valuesHolder1,valuesHolder2,valuesHolder3,valuesHolder4);

objectAnimator.setDuration(3000).start();
```
- 第一个参数是动画的目标对象。
- 第二个参数是PropertyValuesHolder类的实例，可以有多个实例。

值的一提的是PropertyValuesHolder.ofKeyframe,通过控制time/value键值对来实现动画效果。

```
Keyframe keyframe1 = Keyframe.ofFloat(0f, 0f);//第一帧动画 动画完成度0的时候的值是0
Keyframe keyframe2 = Keyframe.ofFloat(0.5f, 200.0f);//第二帧动画 动画完成度0.5也就是一半的时候值是200
Keyframe keyframe3 = Keyframe.ofFloat(1f, 0f);//第三帧动画 动画完成度1也就是动画结束的时候值是0.

PropertyValuesHolder property = PropertyValuesHolder.ofKeyframe("translationX", keyframe1, keyframe2, keyframe3);
ObjectAnimator objectAnimator = ObjectAnimator.ofPropertyValuesHolder(textView, property);
objectAnimator.setDuration(2000).start();
```
通过这种方式我们可以控制动画的播放进度。

##动画监听
我们可能需要在动画开始或者结束的时候执行一些其他的操作，Android给我们提供了动画监听的接口，我们只需要添加监听器就可以了。

```
animator.addListener(new Animator.AnimatorListener() {
	@Override
	public void onAnimationStart(Animator animation) {
		//动画开始
	}

	@Override
	public void onAnimationEnd(Animator animation) {
		//动画结束
	}

	@Override
	public void onAnimationCancel(Animator animation) {
		//动画取消
	}

	@Override
	public void onAnimationRepeat(Animator animation) {
		//动画重复
	}
});
```
有时候我们不需要监听这么多状态，只需要监听其中某个状态，我们可以实现另外一个监听。

```
animator.addListener(new AnimatorListenerAdapter() {
	//可以实现任何一种你需要的监听
	//OnAnimationCancel
	//OnAnimationEnd
	//OnAnimationRepeat
	//OnAnimationStart
	//OnAnimationPause
	//OnAnimationResume
	@Override
	public void onAnimationEnd(Animator animation) {
		super.onAnimationEnd(animation);
	}   
});
```
除此之外还有另外一个比较重要的监听，可以监听到动画每个时刻的属性值

```
animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
	@Override
	public void onAnimationUpdate(ValueAnimator animation) {
		//float value = (float) animation.getAnimatedValue("propertyName");PropertyValuesHolder
		float value = (float) animation.getAnimatedValue();
	}
});
```

##ObjectAnimator自定义属性
上面我们看到的动画都是改变translation，rotation，scale，alpha这四个属性的动画，我们也可以自己定义属性来实现动画。
我们知道**ObjectAnimator 需要指定操作的控件对象，在开始动画时，到控件类中去寻找设置属性所对应的 set 函数，然后把动画中间值做为参数传给这个 set 函数并执行它**。
所以我们需要自定义控件，我们简单的做一个圆形的PointView。

1. 首先定义一个类Point存放控件PointView的属性：

```
public class Point {
    private int mRadius;

    public Point(int mRadius) {
        this.mRadius = mRadius;
    }

    public int getmRadius() {
        return mRadius;
    }

    public void setmRadius(int mRadius) {
        this.mRadius = mRadius;
    }
}
```
只有一个属性，半径。
2. 自定义控件PointView。

```
public class PointView extends View {

    private Point mPoint = new Point(100);

    public PointView(Context context) {
        super(context);
    }

    public PointView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public PointView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (mPoint!=null){
            Paint paint = new Paint();
            paint.setAntiAlias(true);
            paint.setColor(Color.RED);
            paint.setStyle(Paint.Style.FILL);
            canvas.drawCircle(300,300,mPoint.getRadius(),paint);
        }
    }
    void setPointRadius(int radius){
        mPoint.setRadius(radius);
        invalidate();
    }
}
```

3. 使用看看效果

```
pointView = (PointView) findViewById(R.id.pointView);
pointView.setOnClickListener(new View.OnClickListener() {
	@Override
	public void onClick(View v) {
		ObjectAnimator animator = ObjectAnimator.ofInt(pointView, "pointRadius", 0, 500, 100);
		animator.setDuration(2000);
		animator.start();
	});
```

![自定义ObjecAnimator属性](http://img.blog.csdn.net/20160926160352646)
