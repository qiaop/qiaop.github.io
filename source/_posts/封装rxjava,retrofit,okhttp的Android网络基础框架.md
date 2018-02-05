---
title: 封装rxjava,retrofit,okhttp的Android网络基础框架
date: 2017-08-09 14:49:19
tags: 
- http
- rxjava
- retrofit
- okhttp
categories:
- Android

---

[项目地址](https://github.com/qiaop/basicapp)

### 包含的功能

- 主要使用okhttp进行网络通信，封装okhttp日志打印
- 封装Cookie维持
- 封装使用Gson作为默认数据解析转化器
- 统一处理网络回调错误码
- 封装线程切换，进行网络请求不必考虑线程问题
- 封装ApiSubscriber，可设置是否显示ProgressDialog
- 使用rxlifecycle2进行生命周期的处理

基本上满足开发的一般需求。

<!-- more -->

### 使用示例

ApiService
```java
public interface ApiService {
    
    @GET("query")
    Observable<Result<List<Message>>> getMessage(@Query("type") String type, @Query("postid") String postid);
	}

```


```java
public class MainActivity extends RxAppCompatActivity {

    Button button;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        button = (Button) findViewById(R.id.button2);
        
        RetrofitHelper.creatApi(ApiService.class).getMessage("yuantong","200382770316")
                .compose(MainActivity.this.<Result<List<Message>>>bindUntilEvent(ActivityEvent.DESTROY))
                .compose(SchedulerTransformer.<Result<List<Message>>>transformer())
                .map(new ServerResponseFun<List<Message>>())
                .onErrorResumeNext(new HttpResponseFunc<List<Message>>())
                .subscribe(new ApiSubscriber<List<Message>>(MainActivity.this,true,false) {
                    @Override
                    public void onNext(@NonNull List<Message> messages) {
                        button.setText(messages.toString());
                    }
                });


    }
}

```
#### 代码解释
`compose(MainActivity.this.<Result<List<Message>>>bindUntilEvent(ActivityEvent.DESTROY))`
生命周期的处理，Destory时停止网络请求

`compose(SchedulerTransformer.<Result<List<Message>>>transformer())`
线程切换，子线程进行网络请求，主线程处理请求结果

`map(new ServerResponseFun<List<Message>>())`
服务器返回码处理，如果不等于200进行错误处理

`onErrorResumeNext(new HttpResponseFunc<List<Message>>())`
http请求错误统一处理

#### ApiSubscriber

ApiSubscriber对网络请求时需要弹出ProgressDialog和请求错误时弹出Toast进行了封装。

- 可以设置是否显示dialog
- 可以设置是否可以取消
- 可以设置ProgressDialog提示语
- 可以自定义ProgressDialog

