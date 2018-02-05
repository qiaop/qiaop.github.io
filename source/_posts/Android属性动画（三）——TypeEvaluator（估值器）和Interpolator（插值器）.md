---
title: Android属性动画（三）——TypeEvaluator（估值器）和Interpolator（插值器）
date: 2017-01-17 15:36:50
tags:
- android
- csdn
categories:
- Android
	
---

前几篇文章我们介绍了ObjectAnimator和ValueAnimator的基本用法。


## TypeEvaluator(估值器)

细心的朋友会发现我们有一个东西没有用到。

```java
public static ValueAnimator ofObject(TypeEvaluator evaluator, Object... values)
```

<!-- more -->

当我们ValueAnimator.ofObject()函数来做动画效果的时候就会用到估值器了，估值器说白了就是用来确定在动画过程中每时每刻动画的具体值得换句话说就是确定ValueAnimator.getAnimatedValue()返回的具体对象类型。

### 系统内置的估值器有：

- IntEvaluator Int类型估值器，返回int类型的属性改变
- FloatEvaluator Float类型估值器，返回Float类型属性改变
- ArgbEvaluator 颜色类型估值器

### TypeEvaluator源码：

```java
package android.animation;

public interface TypeEvaluator<T> {

    public T evaluate(float fraction, T startValue, T endValue);

}
```
- 第一个参数表示动画完成度。
- 第二个和第三个参数分别是初始值和结束值。


ValueAnimator.ofFloat()方法就是实现了初始值与结束值之间的平滑过度，它内置了一个FloatEvaluator。

```java
package android.animation;

/**
 * This evaluator can be used to perform type interpolation between <code>float</code> values.
 */
public class FloatEvaluator implements TypeEvaluator<Number> {

    public Float evaluate(float fraction, Number startValue, Number endValue) {
        float startFloat = startValue.floatValue();
        return startFloat + fraction * (endValue.floatValue() - startFloat);
    }
}
```
### 自己实现一个估值器

先看看效果。


![TypeEvaluator](http://img.blog.csdn.net/20160928165607945)

#### Point对象存放CircleView的属性

```java
public class Point {
    private float mRadius;
    public float x;
    public float y;

    public Point(float x, float y, float mRadius) {
        this.x = x;
        this.y = y;
        this.mRadius = mRadius;
    }

    public Point() {
    }

    public float getRadius() {
        return mRadius;
    }

    public void setRadius(float mRadius) {
        this.mRadius = mRadius;
    }

    public float getX() {
        return x;
    }

    public void setX(float x) {
        this.x = x;
    }

    public float getY() {
        return y;
    }

    public void setY(float y) {
        this.y = y;
    }
}
```


#### 估值器，这里用了三角函数来计算x，y坐标
```java
public class CircleTypeEvaluator implements TypeEvaluator {
    private float radius;//旋转的半径
    public CircleTypeEvaluator(float radius) {
        this.radius = radius;
    }
    @Override
    public Object evaluate(float fraction, Object startValue, Object endValue) {
        Point point = new Point();
        Point startPoint = (Point) startValue;
        //旋转的角度
        float angle = fraction * 360;
        float longY = (float) ((radius *(1- Math.cos(Math.toRadians(angle)))));//计算y坐标
        point.setY(startPoint.getY() + longY);
        float longX = (float) (radius - radius * Math.sin(Math.toRadians(angle)));//计算x坐标
        point.setX(startPoint.getX() + longX-radius);
        return point;
    }
}
```

#### CircleView

```java
public class CircleView extends View {

    private Paint paint;
    private Point point;

    public CircleView(Context context) {
        super(context);
        init();
    }

    public CircleView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }


    public CircleView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init(){
        paint=new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(getResources().getColor(android.R.color.holo_blue_light));
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (point==null){
            point = new Point(getWidth()/2,getHeight()/2,100);
            canvas.drawCircle(point.x,point.y,point.getRadius(),paint);

        }else{
            canvas.drawCircle(point.getX(),point.getY(),point.getRadius(),paint);
        }
    }

    public void setViewPoint(Point result){
        point.setX(result.getX());
        point.setY(result.getY());
        invalidate();
    }

}
```

#### 使用的时候，这里球的半径是固定的100

```java
circleView.setOnClickListener(new View.OnClickListener() {
	@Override
	public void onClick(View v) {
		Point start = new Point(circleView.getWidth()/2,circleView.getHeight()/2,100);
		
		ValueAnimator animator = ValueAnimator.ofObject(new CircleTypeEvaluator(200),start,start);
		animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
			@Override
			public void onAnimationUpdate(ValueAnimator animation) {
				Point result = (Point) animation.getAnimatedValue();
                circleView.setViewPoint(result);
            }
        });
        animator.setDuration(2000);
        animator.setRepeatCount(-1);
        animator.start();
     }
 });
```
## Interpolator（插值器）
在动画的播放过程中Android中提供插值器来**改变动画的播放速率**，采用不用的插值器来实现不同的播放效果。

大家有没有发现上面我们讲TypeEvaluator的例子，蓝色的小球运动的速率是由慢到快再变慢，因为系统默认的使用的插值器是AccelerateDecelerateInterpolator默认实现这种效果。

Interpolator接口从Android 1.0版本开始就一直存在，我们讲Tween动画的时候就是用过。属性动画中新增了一个TimeInterpolator接口，Interpolator是继承TimeInterpolator接口的。系统已经有很多可以直接使用的类。
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
使用方法很简单

```java
animator.setInterpolator(new AccelerateInterpolator());
```
### 自定义Interpolator

有时候系统提供的实现类并不能满足我们的需求，所以就需要自定义Interpolator。
所有的插值器都要去实现TimeInterpolator接口，TimeInterpolator接口代码如下。

```java
public interface TimeInterpolator {

    /**
     * Maps a value representing the elapsed fraction of an animation to a value that represents
     * the interpolated fraction. This interpolated value is then multiplied by the change in
     * value of an animation to derive the animated value at the current elapsed animation time.
     *
     * @param input A value between 0 and 1.0 indicating our current point
     *        in the animation where 0 represents the start and 1.0 represents
     *        the end
     * @return The interpolation value. This value can be more than 1.0 for
     *         interpolators which overshoot their targets, or less than 0 for
     *         interpolators that undershoot their targets.
     */
    float getInterpolation(float input);
}
```
从代码中可以看到这里只需要实现getInterpolation()函数就好了。

TimeInterpolator接口里面getInterpolation函数的参数input就是动画每一次播放过程中的时间比例值，是0-1之间的值，但是返回的值是可以大于1，也是可以小于0的，对于返回值倒是没什么特定的要求。

### 系统的插值器AccelerateDecelerateInterpolator ：

```java
/**
 * An interpolator where the rate of change starts and ends slowly but
 * accelerates through the middle.
 */
@HasNativeInterpolator
public class AccelerateDecelerateInterpolator extends BaseInterpolator
        implements NativeInterpolatorFactory {
    public AccelerateDecelerateInterpolator() {
    }

    @SuppressWarnings({"UnusedDeclaration"})
    public AccelerateDecelerateInterpolator(Context context, AttributeSet attrs) {
    }

    public float getInterpolation(float input) {
        return (float)(Math.cos((input + 1) * Math.PI) / 2.0f) + 0.5f;
    }

    /** @hide */
    @Override
    public long createNativeInterpolator() {
        return NativeInterpolatorFactoryHelper.createAccelerateDecelerateInterpolator();
    }
}
```
- 构造函数
第一个是无参构造是我们具体JAVA代码中new的时候用到，第二个构造函数是在资源文件里面使用的时候调用的（@android:anim/accelerate_decelerate_interpolator的时候会调用这个构造方法）。
- getInterpolation()方法
AccelerateDecelerateInterpolator插值器的曲线图得到对应的数学表达式(cos((x + 1) * PI) / 2.0) + 0.5，然后数学表达式转换为代码形式，(Math.cos((input + 1) * Math.PI) / 2.0f) + 0.5f。

### 开始定义自己的Interpolator。
第一步确定我们要实现的插值器的曲线图。
第二步数学表达式，需要一定的数学功底
pow(2, -10 * x) * sin((x - factor / 4) * (2 * PI) / factor) + 1 
factor = 0.2 这个我们在构造函数的时候指定
第三步

```java
public class SpringInterpolator implements Interpolator {

    private static final float DEFAULT_FACTOR = 0.2f;

    private float mFactor;

    public SpringInterpolator() {
        this(DEFAULT_FACTOR);
    }

    public SpringInterpolator(float mFactor) {
        this.mFactor = mFactor;
    }

    @Override
    public float getInterpolation(float input) {
        // pow(2, -10 * input) * sin((input - factor / 4) * (2 * PI) / factor) + 1
        return (float) (Math.pow(2, -10 * input) * Math.sin((input - mFactor / 4.0d) * (2.0d * Math.PI) / mFactor) + 1);
    }
}

```

```java
animator.setInterpolator(new SpringInterpolator());
```
看看效果
![SpringInterpolator](http://img.blog.csdn.net/20160929110611752)