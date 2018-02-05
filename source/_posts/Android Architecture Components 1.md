---
title: Android Architecture Components 详解(一)Handling Lifecycles
date: 2017-08-11 14:49:19
tags: 
- Architecture
- 翻译
categories:
- Android

---

# Handling Lifecycles

[英文原文地址](https://developer.android.com/topic/libraries/architecture/lifecycle.html)科学上网

android.arch.lifecycle包提供了类和接口，可以让您构建生命周期感知组件，这些组件可以根据Activity或Fragment的当前生命周期自动调整其行为。
>注意：要将android.arch.lifecycle导入到您的Android项目中，请参阅Adding Components to your Project

<!-- more -->

Android Framework中定义的大多数应用程序组件都附有生命周期。 这些生命周期由您的进程中运行的操作系统或框架代码进行管理。 它们是Android如何工作的核心，您的应用程序必须尊重它们。 不这样做可能会触发内存泄漏甚至应用程序崩溃。

想象一下，我们有一个Activity，显示屏幕上的设备位置。 常见的实现可能如下：

``` java
class MyLocationListener {
    public MyLocationListener(Context context, Callback callback) {
        // ...
    }

    void start() {
        // connect to system location service
    }

    void stop() {
        // disconnect from system location service
    }
}

class MyActivity extends AppCompatActivity {
    private MyLocationListener myLocationListener;

    public void onCreate(...) {
        myLocationListener = new MyLocationListener(this, (location) -> {
            // update UI
        });
  }

    public void onStart() {
        super.onStart();
        myLocationListener.start();
    }

    public void onStop() {
        super.onStop();
        myLocationListener.stop();
    }
}

```

即使这个示例看起来不错，在一个真实的应用程序中，最终会遇到这样太多的调用，而`onStart（）`和`onStop（）`方法变得非常大。

此外，一些组件不能仅仅在`onStart（）`中启动。 如果我们需要在启动位置观察器之前检查一些配置怎么办？ 在某些情况下，可以在Activity Stop后检查完成，这意味着`myLocationListener.start（）`在调用`myLocationListener.stop（）`之后调用，会导致一直保持连接。

``` java
class MyActivity extends AppCompatActivity {
    private MyLocationListener myLocationListener;

    public void onCreate(...) {
        myLocationListener = new MyLocationListener(this, location -> {
            // update UI
        });
    }

    public void onStart() {
        super.onStart();
        Util.checkUserStatus(result -> {
            // what if this callback is invoked AFTER activity is stopped?
            if (result) {
                myLocationListener.start();
            }
        });
    }

    public void onStop() {
        super.onStop();
        myLocationListener.stop();
    }
}

```

`android.arch.lifecycle`包提供了类和接口，帮助您以弹性和隔离的方式解决这些问题。

## Lifecycle

`Lifecycle`是一个类，它保存有关组件生命周期状态的信息（如Activity或Fragment），并允许其他对象观察此状态。

`Lifecycle`使用两个主要枚举来跟踪其关联组件的生命周期状态。

Event

*　　*从Framwork和`Lifecycle`类分发的生命周期事件。 这些事件映射到Activity和Fragment中的回调事件。

State

*　　*由Lifecycle对象跟踪的组件的当前状态。


![](/images/post/android/lifecycle-states.png)

将状态视为图形和事件的节点作为这些节点之间的边缘。

类可以通过向其方法添加注解来监视组件的生命周期状态。

``` java
public class MyObserver implements LifecycleObserver {
    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    public void onResume() {
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    public void onPause() {
    }
}
aLifecycleOwner.getLifecycle().addObserver(new MyObserver());

```

## LifecycleOwner
LifecycleOwner是一个单一的方法接口，表示该类有一个Lifecycle。 它有一个方法，getLifecycle（），它必须由类实现。

此类从各个类（例如，Activity和Fragment）抽象Lifecycle的所有权，并允许编写可与两者兼容的组件。 任何自定义应用程序类都可以实现LifecycleOwner接口。

>注意：由于架构组件处于Alpha阶段，因此Fragment和AppCompatActivity类无法实现（因为我们无法将稳定组件的依赖关系添加到不稳定的API）。 在Lifecycle稳定之前，为了方便起见，提供了LifecycleActivity和LifecycleFragment类。 Lifecycle项目发布后，支持库Fragment和Activity将实现LifecycleOwner接口; 届时将不推荐使用LifecycleActivity和LifecycleFragment。 另请参阅在自定义Activity和Fragment中实现LifecycleOwner。

对于上面的示例，我们可以使MyLocationListener类成为`LifecycleObserver`，然后使用onCreate中的`Lifecycle`来初始化它。 这允许MyLocationListener类自给自足，这意味着它可以在必要时进行自己的清理。

``` java
class MyActivity extends LifecycleActivity {
    private MyLocationListener myLocationListener;

    public void onCreate(...) {
        myLocationListener = new MyLocationListener(this, getLifecycle(), location -> {
            // update UI
        });
        Util.checkUserStatus(result -> {
            if (result) {
                myLocationListener.enable();
            }
        });
  }
}
```

一个常见的用例是避免在Lifecycle目前处于不良状态时调用某些回调。 例如，如果在Activity state is saved后回调运行fragment transaction，则会触发崩溃，因此我们永远不会想要调用该回调。

为了简化此用例，Lifecycle类允许其他对象查询当前状态。

``` java
class MyLocationListener implements LifecycleObserver {
    private boolean enabled = false;
    public MyLocationListener(Context context, Lifecycle lifecycle, Callback callback) {
       ...
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    void start() {
        if (enabled) {
           // connect
        }
    }

    public void enable() {
        enabled = true;
        if (lifecycle.getState().isAtLeast(STARTED)) {
            // connect if not connected
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    void stop() {
        // disconnect if connected
    }
}
```

通过这种实现，我们的LocationListener类是完全生命周期感知的; 它可以进行自己的初始化和清理，而不受该活动的管理。 如果我们需要从另一个活动或另一个片段使用我们的LocationListener，我们只需要初始化它。 所有的设置和拆卸操作都由类本身管理。

可以与Lifecycle一起工作的类称为生命周期感知(lifecycle-aware)组件。 鼓励提供需要使用Android生命周期的类的库提供生命周期感知(lifecycle-aware)组件，以便客户端可以轻松地在客户端上集成这些类，而无需手动生命周期管理。

`LiveData`是生命周期感知组件的示例。 与`ViewModel`一起使用`LiveData`可以在遵循Android生命周期的情况下，更容易地使用数据填充UI。

## Lifecycles最佳用法

- 保持您的UI Controller（Activity和Fragment）尽可能瘦。 他们不应该试图获取自己的数据; 而是使用`ViewModel`来执行此操作，并观察`LiveData`以将更改反映到视图中。
- 尝试编写（data-driven）数据驱动的UI，您的UI控制器的责任是在数据更改时更新视图，或将用户操作通知给ViewModel。
- 将您的数据逻辑放在`ViewModel`类中。 `ViewModel`应该用作UI控制器和其他应用程序之间的连接器。 请注意，`ViewModel`不是提取数据（例如，从网络）的责任。 相反，`ViewModel`应该调用相应的组件来执行此操作，然后将结果提供给UI控制器。
- 使用 Data Binding来保持视图和UI控制器之间的clean interface。 这样可以让您的视图更具声明性，并尽可能减少您在Activity和Fragment中编写的更新代码。 如果您更喜欢在Java中执行此操作，请使用像ButterKnife这样的库来避免使用样板代码并进行更好的抽象。
- 如果您的UI很复杂，请考虑创建一个Presenter类来处理UI修改。 这通常是过度的，但可能会使您的UI更容易测试。
- 不要在ViewModel中引用View或Activity上下文。 如果ViewModel超过Activity（在配置更改的情况下），您的Activity将被泄漏，而不是正确的垃圾回收。

## 附录
### 在自定义Activity和Fragment中实现LifecycleOwner

任何自定义Fragment或Activity都可以通过实现内置的LifecycleRegistryOwner接口（而不是扩展LifecycleFragment或LifecycleActivity）来转换为LifecycleOwner。

``` java
public class MyFragment extends Fragment implements LifecycleRegistryOwner {
    LifecycleRegistry lifecycleRegistry = new LifecycleRegistry(this);

    @Override
    public LifecycleRegistry getLifecycle() {
        return lifecycleRegistry;
    }
}
```

如果您有一个要创建LifecycleOwner的自定义类，则可以使用LifecycleRegistry类，但是您需要将事件转发到该类中。 如果Fragment和Activity实现了LifecycleRegistryOwner接口，则此转发将自动完成。

<hr>

下期[Android Architecture Components 详解(二)LiveData](http://www.codepeng.cn/2017/08/15/Android%20Architecture%20Components%202/)