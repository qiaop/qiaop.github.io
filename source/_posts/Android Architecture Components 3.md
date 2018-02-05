---
title: Android Architecture Components 详解(三)ViewModel
date: 2017-08-15 16:57:19
tags: 
- Architecture
- 翻译
categories:
- Android

---
ViewModel类旨在存储和管理与UI相关的数据，以便数据在诸如屏幕旋转之类的配置更改中保存下来。

[英文原文地址](https://developer.android.com/topic/libraries/architecture/viewmodel.html)科学上网

>注意：要将 ViewModel 导入到您的Android项目中，请参阅[adding components to your project](http://www.codepeng.cn/2017/08/10/Android%20Architecture%20Components%200/)

App组件（如activities和fragments）具有由Android Framework管理的生命周期。 Framework可能会根据完全不受控制的某些用户操作或设备事件来决定销毁或重新创建它们。

由于这些对象可能被操作系统销毁或重新创建，因此您所拥有的任何数据都可能丢失。 例如，如果您的activity中有用户列表，当配置更改，重新创建activity时，新的activity必须重新获取用户列表。 对于简单的数据，activity可以使用onSaveInstanceState（）方法，并从onCreate（）中的bundle中恢复其数据，但这种方法仅适用于少量数据，如UI状态，而不适用于大量数据，如列表 的用户。

<!-- more -->

另一个问题是，这些UI控制器（activities，fragments等）经常需要进行一些可能需要一些时间返回的异步调用。 UI控制器需要管理这些调用，并在被销毁时清理它们，以避免潜在的内存泄漏。 这需要大量维护，并且在配置更改的情况下重新创建对象，由于需要重新发出相同的调用，因此浪费资源。

最后但并非最不重要的是，这些UI控制器已经需要对用户操作做出反应或处理操作系统的通信。 当他们也需要手动处理他们的资源时，它会变得很臃肿，导致“god activities”（或“god fragments”）; 也就是说，一个单独的类尝试自己处理所有的应用程序的工作，而不是将工作委派给其他类。 这也使得测试变得更加困难。

将视图数据所有权与UI控制器逻辑分离是更简洁和更有效的。 Lifecycles提供了一个名为ViewModel的新类，它是UI控制器的辅助类，负责为UI准备数据。 在配置更改的时候，ViewModel将自动保留，以便其保存的数据立即可用于下一个Activity或Fragment实例。 在我们上面提到的例子中，ViewModel应该是获取和保留用户列表而不是活动或片段的责任。

``` java
public class MyViewModel extends ViewModel {
    private MutableLiveData<List<User>> users;
    public LiveData<List<User>> getUsers() {
        if (users == null) {
            users = new MutableLiveData<List<Users>>();
            loadUsers();
        }
        return users;
    }

    private void loadUsers() {
        // do async operation to fetch users
    }
}

```

现在activity可以这样访问列表：

``` java
public class MyActivity extends AppCompatActivity {
    public void onCreate(Bundle savedInstanceState) {
        MyViewModel model = ViewModelProviders.of(this).get(MyViewModel.class);
        model.getUsers().observe(this, users -> {
            // update UI
        });
    }
}

```

如果activity重新创建，它将收到由上一个activity创建的相同的MyViewModel实例。 当所有者活activity完成时，框架调用ViewModel的onCleared（）方法，以便它可以清理资源。

>**注意**：由于ViewModel超出了特定的activity和fragment实例，所以它不能引用View或任何可能持有对activity的Context引用的类。 如果ViewModel需要应用程序上下文（例如，找到系统服务），则可以扩展AndroidViewModel类，并在构造函数中接收应用程序的构造函数（由于 Application class extends Context）。


## 在Fragment之间共享数据
 
 非常常见的是，Activity中的两个或多个Fragment需要相互通信。 这非常麻烦的，因为两个Fragment都需要定义一些接口描述，而所有者Activity必须将两者绑定在一起。 此外，两个Fragment都必须处理其他Fragment尚未创建或不可见的情况。
 
 通过使用ViewModel对象可以解决这个常见的痛点。 想象一下master-detail Fragment的常见情况，其中我们有一个fragment，用户从列表中选择一个项目，另一个fragment显示所选项目的内容。
 
 这些fragment可以在其activity范围共享一个ViewModel来处理此通信。
 
 ``` java
 public class SharedViewModel extends ViewModel {
    private final MutableLiveData<Item> selected = new MutableLiveData<Item>();

    public void select(Item item) {
        selected.setValue(item);
    }

    public LiveData<Item> getSelected() {
        return selected;
    }
}

public class MasterFragment extends Fragment {
    private SharedViewModel model;
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        model = ViewModelProviders.of(getActivity()).get(SharedViewModel.class);
        itemSelector.setOnClickListener(item -> {
            model.select(item);
        });
    }
}

public class DetailFragment extends LifecycleFragment {
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SharedViewModel model = ViewModelProviders.of(getActivity()).get(SharedViewModel.class);
        model.getSelected().observe(this, { item ->
           // update UI
        });
    }
}

 ```
 
 请注意，在获取ViewModelProvider时，两个fragment都使用getActivity()。 这意味着他们都将收到相同的SharedViewModel实例，该实例是activity范围内的。
 
 这种方法的好处包括：
 
 - activity不需要做任何事情，也不知道有关此通信的任何内容。
 - 除了SharedViewModel联系之外，fragment不需要彼此了解。 如果其中一个消失，另一个会照常工作。
 - 每个fragment都有自己的生命周期，不受其他fragment的生命周期的影响。 实际上，在一个fragment替换另一个fragment的UI中，UI工作不会有任何问题。
 
 
## ViewModel的生命周期
当创建一个ViewModel时，它的生命周期会被托管给ViewModelProvider，ViewModel一旦被创建就会常驻于内存，除非特定情形导致其销毁。比如activity finished,或者fragment detach from activity。

![](https://developer.android.com/images/topic/libraries/architecture/viewmodel-lifecycle.png)

 
## ViewModel vs SavedInstanceState
ViewModels提供了一种方便的方法来在配置更改之间保留数据，但如果应用程序被操作系统杀死，则它们不会被保存。

例如，如果用户离开应用程序并在几小时后回来，那么该进程将被杀死，Android操作系统将从saved state恢复activity。所有框架组件（View，Activity，Fragment）使用saved instance state机制保存其状态，所以大多数时候，您不必做任何事情。您可以使用onSaveInstanceState回调将自定义数据添加到bundle中。

通过onSaveInstanceState保存的数据保存在系统进程内存中，Android操作系统允许您只保留非常少量的数据，因此它不应该保存应用程序实际数据。你应该谨慎地使用它不容易被UI组件表示的东西。

例如，如果您的用户界面显示有关国家/地区的信息，则不应将Country对象置于saved instance state。您可以将countryId保存为saved state（除非已由View或Fragment参数保存）。实际的对象应该存在于数据库中，ViewModel可以使用保存的countryId来检索它。