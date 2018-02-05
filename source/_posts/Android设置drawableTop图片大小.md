---
title: Android设置drawableTop图片大小
date: 2017-01-18 11:56
tags: 
- skill
categories:
- Android

---
在开发中我们经常用到TextView、Button、RadioButton这三个控件，很多时候我们需要文字和图片一起出现，很多应用的底部的导航栏用RadioGroup来实现切换的功能，例如QQ等等，这时候我们要用RadioButton的drawableTop、drawableLeft、drawableRight、drawableBottom四个属性值，来设定文字对应方向的图片，但是却没有设置图片大小的属性值。

<!-- more -->

要想设置这些图片的大小其实很简单，我们要了解一下下面几个方法：

 - **getCompoundDrawables()** 该方法返回包含控件左,上,右,下四个位置的Drawable的数组
 - **setBounds(left,top,right,bottom)**指定drawable的边界
 - **setCompoundDrawables(drawableLeft, drawableTop, drawableRight, drawableBottom)**设置控件左,上,右,下四个位置的Drawable

Button、RadioButton其实都是TextView的子类，这三个方法都是TextView里的方法

**所以流程就是，我们首先拿到控件上面位置的drawable，然后给指定drawable的边界，最后再把drawable设置进去**

这个例子是一个RadioGroup里有五个RadioButton，分别有drawableTop图片

```
	/**
	 * 设置底部按钮
	 */
	public void initButton(){
		for (int i = 0; i < radioIds.length; i++) {//循环

			drawables = radioBtns[i].getCompoundDrawables();
			//通过RadioButton的getCompoundDrawables()方法，拿到图片的drawables,分别是左上右下的图片,这里设置的是上部的图片所以drawables[1]。
			
			switch (i) {//为每一个drawableTop设置属性setBounds(left,top,right,bottom)
			case 0:
				drawables[1].setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.x18),
						getResources().getDimensionPixelSize(R.dimen.x24));
				break;

			case 1:
				drawables[1].setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.x25),
						getResources().getDimensionPixelSize(R.dimen.x25));
				break;
			case 2:
				drawables[1].setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.x40),
						getResources().getDimensionPixelSize(R.dimen.x25));
				break;
			case 3:
				drawables[1].setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.x25),
						getResources().getDimensionPixelSize(R.dimen.x25));
				break;
			case 4:
				drawables[1].setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.x25),
						getResources().getDimensionPixelSize(R.dimen.x25));
				break;
			default:
				break;
			}
			
			radioBtns[i].setCompoundDrawables(drawables[0], drawables[1], drawables[2],
					drawables[3]);//将改变了属性的drawable再重新设置回去
		}
		radioBtns[0].setChecked(true);
	}
```