---
title: TabLayout使用以及自定义TabLayout的item
date: 2017-01-16 19:36:50
tags:
- SupportDesign
categories:
- Android

---

TabLayout是属于Android Design Support Library中的一个控件，顶部或者底部水平的Tab布局，滑动或者点击切换的功能，今天我们简单讲解TabLayout的使用，重点讲解如何自定义TabLayout的item，也就是每一个tab。
首先看看GooglePlay的这个界面。

<!-- more -->

<img src="http://img.blog.csdn.net/20161207143203925?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvcWlhbzA4MDk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast" widht="320" height = "480" >

## TabLayout使用

### 添加依赖

```
compile 'com.android.support:design:23.4.0'
```
### 布局

```xml
    <android.support.design.widget.TabLayout
        android:layout_width="match_parent"
        android:layout_height="40dp"
        android:id="@+id/tablayout">
    </android.support.design.widget.TabLayout>

    <android.support.v4.view.ViewPager
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:id="@+id/viewpager">
```
通常我们都搭配ViewPager+Fragment使用。
页面用Fragment，放了一个小图标。
然后是ViewPager的适配器：
```
public class FragmentAdapter extends FragmentPagerAdapter {

    private String [] title = {"one","two","three","four"};
    private List<Fragment> fragmentList;
    public FragmentAdapter(FragmentManager fm,List<Fragment> fragmentList) {
        super(fm);
        this.fragmentList = fragmentList;
    }
    @Override
    public Fragment getItem(int position) {
        return fragmentList.get(position);
    }
    @Override
    public int getCount() {
        return fragmentList.size();
    }
    @Override
    public CharSequence getPageTitle(int position) {
        return title[position];
    }
}
```
MainActivity：

```java
@Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ButterKnife.bind(this);

        ContentFragment fragment1 = new ContentFragment();
        ContentFragment fragment2 = new ContentFragment();
        ContentFragment fragment3 = new ContentFragment();
        ContentFragment fragment4 = new ContentFragment();
        fragments.add(fragment1);
        fragments.add(fragment2);
        fragments.add(fragment3);
        fragments.add(fragment4);
        adapter = new FragmentAdapter(getSupportFragmentManager(),fragments);
        viewpager.setAdapter(adapter);
        tablayout.setupWithViewPager(viewpager);
    }
```
看看效果：

![这里写图片描述](http://img.blog.csdn.net/20161207162845680?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvcWlhbzA4MDk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

完成了，大家注意最后一行代码，作用是将TabLayout与ViewPager连接起来，其实看源码也就知道是通ViewPager的OnPageChangeListener监听连接起来的。

但是有一点要**注意**，setupWithViewPager这个方法会先将tab清除然后再根据ViewPager的adapter里的count去取pagetitle，这也就是有些同学遇到用addTab方法添加tab不起作用的问题。



当然TabLayout还有很多api可以使用，来改变TabLayout的样式，添加图标，以及滚动模式等等。


![这里写图片描述](http://img.blog.csdn.net/20161207171126865?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvcWlhbzA4MDk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 自定义TabItem
当这些api都不能满足你的要求的时候，我们想自己控制每一个tab怎么显示显示什么内容。
ok，我不想要TabLayout下面的那条横线可以把它设置为0dp。

```xml
app:tabIndicatorHeight="0dp"
```
### item布局

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical">

    <TextView
        android:id="@+id/tab_text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:background="@drawable/tab_background"
        android:padding="10dp"
        android:textColor="@drawable/tab_text_color"
        android:textSize="24sp" />
</LinearLayout>
```
我这里写的比较简单，只有一个TextView。
### MainActivity
先把adapter里写的title注释掉。

```
//private String [] title = {"one","two","three","four"};

//    @Override
//    public CharSequence getPageTitle(int position) {
//        return title[position];
//    }
```

```java
        fragments.add(new ContentFragment());
        fragments.add(new ContentFragment());
        fragments.add(new ContentFragment());
        fragments.add(new ContentFragment());
        fragments.add(new ContentFragment());
        fragments.add(new ContentFragment());
        fragments.add(new ContentFragment());
        fragments.add(new ContentFragment());
        fragments.add(new ContentFragment());

        adapter = new FragmentAdapter(getSupportFragmentManager(), fragments);
        viewpager.setAdapter(adapter);

        tablayout.setupWithViewPager(viewpager);

        for (int i = 0; i < adapter.getCount(); i++) {
            TabLayout.Tab tab = tablayout.getTabAt(i);//获得每一个tab
            tab.setCustomView(R.layout.tab_item);//给每一个tab设置view
            if (i == 0) {
                // 设置第一个tab的TextView是被选择的样式
                tab.getCustomView().findViewById(R.id.tab_text).setSelected(true);//第一个tab被选中
            }
            TextView textView = (TextView) tab.getCustomView().findViewById(R.id.tab_text);
            textView.setText(titles[i]);//设置tab上的文字
        }
        tablayout.setOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                tab.getCustomView().findViewById(R.id.tab_text).setSelected(true);
                viewpager.setCurrentItem(tab.getPosition());
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {
                tab.getCustomView().findViewById(R.id.tab_text).setSelected(false);
            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {

            }
        });
```
ok,大功告成。看效果
![这里写图片描述](http://img.blog.csdn.net/20161207174624880?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvcWlhbzA4MDk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
