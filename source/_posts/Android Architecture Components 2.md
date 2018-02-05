---
title: Android Architecture Components 详解(二)LiveData
date: 2017-08-15 11:24:19
tags: 
- Architecture
- 翻译
categories:
- Android

---
LiveData是一个数据持有者类，它保留一个值，并允许观察该值。 与常规可观察的不同，LiveData遵循应用程序组件的生命周期，以便Observer可以指定应遵守的Lifecycle。

[英文原文地址](https://developer.android.com/topic/libraries/architecture/livedata.html)科学上网

>注意：要将LiveData导入到您的Android项目中，请参阅[adding components to your project](http://www.codepeng.cn/2017/08/10/Android%20Architecture%20Components%200/)

 如果 Observer的 Lifecycle 在 STARTED 或者 RESUMED 状态，那么 LiveData 认为 Observer在一个活动状态。
 
 <!-- more -->
 
 ``` java
 public class LocationLiveData extends LiveData<Location> {
    private LocationManager locationManager;

    private SimpleLocationListener listener = new SimpleLocationListener() {
        @Override
        public void onLocationChanged(Location location) {
            setValue(location);
        }
    };

    public LocationLiveData(Context context) {
        locationManager = (LocationManager) context.getSystemService(
                Context.LOCATION_SERVICE);
    }

    @Override
    protected void onActive() {
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, listener);
    }

    @Override
    protected void onInactive() {
        locationManager.removeUpdates(listener);
    }
}
 ```
 
Location listener 的这种实现有三个重要的部分：

**onActive()**

*　　*当LiveData具有活动的观察者时，将调用此方法。 这意味着我们需要从设备开始观察位置更新。

**onInactive()**

*　　*当LiveData没有任何活动的观察者时，将调用此方法。 由于没有观察者正在收听，所以没有理由保持与LocationManager服务的连接。 这是重要的，因为保持连接消耗电池电量。

**setValue()**

*　　*调用此方法可更新LiveData实例的值，并通知活动的观察者。

我们可以使用新的LocationLiveData如下：

``` java
public class MyFragment extends LifecycleFragment {
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LiveData<Location> myLocationListener = ...;
        Util.checkUserStatus(result -> {
            if (result) {
                myLocationListener.observe(this, location -> {
                    // update UI
                });
            }
        });
    }
}
```
可能有多个Fragment和Activity正在观察我们MyLocationListener实例，LiveData优雅地管理它们，使其连接到系统服务只有他们中一个可见的（即活动状态的）。

LiveData类具有以下优点：

- **没有内存泄漏**：由于观察者绑定到自己的Lifecycle对象，它们的Lifecycle销毁时会自动清除。
- **activities的停止不会导致崩溃**：如果Observer的Lifecycle处于非活动状态（如在后台的Activity），则不会收到更改事件。
- **始终保持最新的数据**：如果Lifecycle再次启动（如从后台切换到前台的Activity），它会收到最新的位置数据（如果还没有）。
- **妥善处理配置的更改**：如果由于配置更改（如设备旋转）重新创建Activity或者Fragment则会立即接收到最后一个可用的数据。
- **共享资源**：现在我们可以保留一个MyLocationListener实例，连接到系统服务只需一次，并且正确地支持应用中的所有观察者。
- **不用手动处理生命周期**：您可能会注意到，我们的Fragment只是在需要时观察数据，不用担心停止或停止后开始观察。 LiveData自动管理所有这一切，因为片段在观察时提供了Lifecycle 。

## LiveData的转换
有时候，您可能希望在将其发送给观察者之前对LiveData值进行更改，或者您可能需要根据另一个LiveData实例的值返回不同的LiveData实例。

Lifecycle包提供了一个Transformations类，其中包含这些操作的帮助方法。

**Transformations.map()**

*　　*在LiveData值上应用一个函数，并将结果传播到下游。

``` java
LiveData<User> userLiveData = ...;
LiveData<String> userName = Transformations.map(userLiveData, user -> {
    user.name + " " + user.lastName
});
```
**Transformations.switchMap()**

与map（）类似，将一个函数应用于该值并解包展开并将结果分派到下游。 传递给switchMap（）的函数必须返回一个Lifecycle。

``` java
private LiveData<User> getUser(String id) {
  ...;
}

LiveData<String> userId = ...;
LiveData<User> user = Transformations.switchMap(userId, id -> getUser(id) );

```

使用这些转换允许在整个链中携带观察者Lifecycle信息，以便不计算这些转换，除非观察者观察到返回的LiveData。 转换的这种懒惰的计算性质允许隐式地传递与生命周期相关的行为，而不添加显式调用或依赖关系。

每当您认为在ViewModel中需要一个Lifecycle对象时，转换可能就是解决方案。

例如，假设我们有一个UI，用户输入一个地址，他们会收到该地址的邮政编码。 这个UI的ViewModel可能是这样的：

``` java
class MyViewModel extends ViewModel {
    private final PostalCodeRepository repository;
    public MyViewModel(PostalCodeRepository repository) {
       this.repository = repository;
    }

    private LiveData<String> getPostalCode(String address) {
       // DON'T DO THIS
       return repository.getPostCode(address);
    }
}

```

如果这样实现，则UI将需要从先前的LiveData注销，并在每次调用getPostalCode（）时重新注册到新实例。 此外，如果UI被重新创建，它会触发对repository.getPostCode（）的另一个调用，而不是使用以前的调用结果。

如果使用转换实现，您可以实现邮政编码信息作为地址输入的转换：

``` java
class MyViewModel extends ViewModel {
    private final PostalCodeRepository repository;
    private final MutableLiveData<String> addressInput = new MutableLiveData();
    public final LiveData<String> postalCode =
            Transformations.switchMap(addressInput, (address) -> {
                return repository.getPostCode(address);
             });

  public MyViewModel(PostalCodeRepository repository) {
      this.repository = repository
  }

  private void setInput(String address) {
      addressInput.setValue(address);
  }
}

```

请注意，我们使邮政编码字段为public final，因为它永远不会更改。 它被定义为addressInput的转换，这样当addressInput发生更改时，如果有活动的观察者，则调用repository.getPostCode（）。 如果在通话时没有主动的观察员，在添加观察者之前不进行任何计算。

该机制允许较低级别的应用程序创建懒惰计算的LiveData对象。 ViewModel可以轻松获取它们，并在其上定义转换规则。

## 创建新的transformations

有十几种不同的具体转换可能在您的应用程序中有用，但默认下不提供它们。 要实现自己的转换，您可以使用MediatorLiveData类，该类专门创建以监听其他LiveData实例并处理它们发出的事件。 MediatorLiveData需要注意将其活动/非活动状态正确传播到源LiveData。 有关详细信息，可以检查Transformations类的实现。

<hr>
下期：[Android Architecture Components 详解(三)ViewModel](http://www.codepeng.cn/2017/08/15/Android%20Architecture%20Components%203/)