---
title: Android中异步任务AsyncTask
date: 2018-05-17 20:12:45
tags:
- 线程
categories:
- Android

---

在Android中线程分为主线程和子线程，主线程主要处理界面相关的事情，而子线程则往往用于执行耗时从操作。在Java中默认情况下一个进程只有一个线程，这个线程就是主线程。子线程也叫工作线程，除了主线程以为的线程都是子线程。

## Android中的线程形态
除了Thread以外，还有AsyncTask、IntentService以及HandlerThread，这三者的本质依然是传统的线程。AsyncTask底层用到了线程池，而IntentService和HandlerThread底层直接使用了线程。

- AsyncTask封装了Thread和Handler，主要是方便开发者在子线程中更新UI。
- HandlerThread是一种具有消息循环的线程，在它内部可以使用Handler。
- IntentService是一个服务，系统对其进行了封装使其可以更方便地执行后台任务，内部采用HandlerThread来执行任务，当任务执行完毕后IntentService会自动退出。作为四大组件中的一个它不容易被系统杀死从而可以尽量保证任务的执行。


<!-- more -->

## AsyncTask

AsyncTask常用于可以在几秒钟完成的后台任务

**AsyncTask基于线程池封装了Thread和Handler，通过AsyncTask可以方便地执行后台任务以及在子线程中访问UI，是一种轻量级的异步任务类。**

**AsyncTask不适合进行特别耗时的后台任务，对于特别耗时的任务来说，建议使用线程池**
### 构造方法
AsyncTask 是一个抽象的泛型类，它提供了 Params、Progerss 和 Result 这三个泛型参数，其中 Params 表示参数的类型，Progress 表示后台任务执行进度的类型，而 Result 则表示后台任务的返回结果的类型，如果不需要传递具体的参数，那么这三个泛型参数可以使用 Void 来代替：

```java
public abstract class AsyncTask<Params, Progress, Result>

```
### 四个核心方法
- **onPreExecute()**

```java
在主线程执行，在异步任务执行之前，主要做一些准备工作，界面的初始化等。
```

- **doInBackground(Params... params)**

```java
在线程池中执行，此方法用于执行异步任务。params参数表示异步任务的输入参数。
在此方法中可以调用publishProgress方法来更新任务的进度，publishProgress方法会调用onProgressUpdate方法。
此方法要返回结果给onPostExecute方法。
```

- **onProgressUpdate(Progress... values)**
	
```java
主线程执行，更新任务进度。
```

- **onPostExecute(Result result)**

```java
在主线程中执行，当异步任务执行完毕并通过return语句进行返回时，这个方法就很快会被调用
```
除了这四个主要的方法还有一个`onCancelled()`方法，当异步任务被取消时会被调用，**onPostExecute()**方法就不会被调用。


- AsyncTask的类必须在主线程中加载。
- AsyncTask的对象必须在主线程中创建。
- execute方法必须在主线程中调用。
- 不要再程序中直接调用`onPreExecute()`、`onPostExecute()`、`doInBackground()`和`onProgressUpdate()`方法。
- 一个AsyncTask对象只能执行一次，即只能调用一次execute方法。

**在Android1.6之前，AsyncTask是串行执行任务的，Android1.6的时候开始采用线程池并行处理任务。但从Android3.0开始，为了避免AsyncTask带来的并发错误，又采用一个线程来串行执行任务。但是我们仍然可以通过AsyncTask的executeOnExecutor方法来并行地执行任务。**

### AsyncTask的工作原理

这个东西还是看源码比较清晰，一次看不懂多看几次，找找博客看看书再看几次就懂了。

AsyncTask 里有一个 static 的 `SerialExecutor`线程池，还有一个`THREAD_POOL_EXECUTOR`线程池。这个`SerialExecutor`里维护了一个`ArrayDeque<Runnable>`，`ArrayDeque`双端队列，不了解不要紧，你只要知道他是一个队列。

1. 在`AsyncTask`执行`execute()`方法的时候，会把我们要执行的Runnable加入到`SerialExecutor`线程池队列里，然后`THREAD_POOL_EXECUTOR`线程池会一个一个地去真正执行这个队列里的Runnable。

2. 在`AsyncTask`的构造方法中实例化了一个`WorkerRunnable<Params, Result>`mWorker对象，`WorkerRunnable`继承了`Callable`，这个`Callable`其实就是一个有返回值的`Runnable`。在mWorker对象的`Call`方法（类比`Runnable`的`run`方法）里调用了`doInBackground(mParams)`方法，也就是我们在使用时重写的`doInBackground`方法。然后使用`FutureTask<Result>`包装了mWorker生成一个新对象mFuture，它既可以作为Runnable被线程执行，又可以作为Future得到Callable的返回值。
3. 这时就到了我们第一步讲的，这里的mFuture最终会被当成我们要执行的Runnable。

**好了，总结一下。**

首先系统会把`AsyncTask`的`Params`参数封装为`FutureTask`对象，`FutureTask`是一个并发类，在这里它充当了`Runnable`的作用。接着这个`FutureTask`会交给`SerialExecutor`的`execute`方法去处理，`SerialExecutor`的`execute`方法首先会把`FutureTask`对象插入到任务队列`mTasks`中，如果这个时候没有正在活动的`AsyncTask`任务，那么就会调用`SerialExecutor`的`scheduleNext`方法来执行下一个`AsyncTask`任务。同时当一个`AsyncTask`任务执行完后，`AsyncTask`会继续执行其他任务直到所有任务都被执行为止。

此外，AysncTask中还有一个InternalHandler，用于将执行环境从线程池切换到主线程。静态的Handler对象，要求必须在主线程创建。

那我们在继承使用`AsyncTask`的时候重写的那几个方法是在什么时候调用的呢？我们结合源码看一看。

`AsyncTask`的`execute`方法最终调用的是`executeOnExecutor`方法。

```
    @MainThread
    public final AsyncTask<Params, Progress, Result> execute(Params... params) {
        return executeOnExecutor(sDefaultExecutor, params);
    }

```

```java
    @MainThread
    public final AsyncTask<Params, Progress, Result> executeOnExecutor(Executor exec,
            Params... params) {
        if (mStatus != Status.PENDING) {
            switch (mStatus) {
                case RUNNING:
                    throw new IllegalStateException("Cannot execute task:"
                            + " the task is already running.");
                case FINISHED:
                    throw new IllegalStateException("Cannot execute task:"
                            + " the task has already been executed "
                            + "(a task can be executed only once)");
            }
        }

        mStatus = Status.RUNNING;

        onPreExecute();

        mWorker.mParams = params;
        exec.execute(mFuture);

        return this;
    }

```
在`executeOnExecutor`方法里调用了`onPreExecute()`方法，并且把参数`params `赋值给`mWorker.mParams`。

在`AsyncTask`的构造方法中：

```java
    public AsyncTask(@Nullable Looper callbackLooper) {
        mHandler = callbackLooper == null || callbackLooper == Looper.getMainLooper()
            ? getMainHandler()
            : new Handler(callbackLooper);

        mWorker = new WorkerRunnable<Params, Result>() {
            public Result call() throws Exception {
                mTaskInvoked.set(true);
                Result result = null;
                try {
                    Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
                    //noinspection unchecked
                    result = doInBackground(mParams);
                    Binder.flushPendingCommands();
                } catch (Throwable tr) {
                    mCancelled.set(true);
                    throw tr;
                } finally {
                    postResult(result);
                }
                return result;
            }
        };

        mFuture = new FutureTask<Result>(mWorker) {
            @Override
            protected void done() {
                try {
                    postResultIfNotInvoked(get());
                } catch (InterruptedException e) {
                    android.util.Log.w(LOG_TAG, e);
                } catch (ExecutionException e) {
                    throw new RuntimeException("An error occurred while executing doInBackground()",
                            e.getCause());
                } catch (CancellationException e) {
                    postResultIfNotInvoked(null);
                }
            }
        };
    }

```

我们可以看到`WorkerRunnable`的`Call`方法中调用了`doInBackground(mParams)`，而这个`Call`方法是会在线程池执行的时候调用。

我们再来看`InternalHandler`用于将线程池切换到主线程的`Handler`。

```java
    private static class InternalHandler extends Handler {
        public InternalHandler(Looper looper) {
            super(looper);
        }

        @SuppressWarnings({"unchecked", "RawUseOfParameterizedType"})
        @Override
        public void handleMessage(Message msg) {
            AsyncTaskResult<?> result = (AsyncTaskResult<?>) msg.obj;
            switch (msg.what) {
                case MESSAGE_POST_RESULT:
                    // There is only one result
                    result.mTask.finish(result.mData[0]);
                    break;
                case MESSAGE_POST_PROGRESS:
                    result.mTask.onProgressUpdate(result.mData);
                    break;
            }
        }
    }

```
当收到`MESSAGE_POST_PROGRESS`消息的时候会调用`onProgressUpdate`方法：
当收到`MESSAGE_POST_RESULT`消息的时候会执行`finish`方法：

```java
    private void finish(Result result) {
        if (isCancelled()) {
            onCancelled(result);
        } else {
            onPostExecute(result);
        }
        mStatus = Status.FINISHED;
    }

```

这里会判断是否被取消，如果没有取消就调用`onPostExecute(result)`否则调用`onCancelled(result)`。

我们看看这两个消息是什么时候发出的。

- 首先是`MESSAGE_POST_RESULT`

```java
    private Result postResult(Result result) {
        @SuppressWarnings("unchecked")
        Message message = getHandler().obtainMessage(MESSAGE_POST_RESULT,
                new AsyncTaskResult<Result>(this, result));
        message.sendToTarget();
        return result;
    }

```

```
    private void postResultIfNotInvoked(Result result) {
        final boolean wasTaskInvoked = mTaskInvoked.get();
        if (!wasTaskInvoked) {
            postResult(result);
        }
    }

```

追一下看到会在构造方法中创建`FutureTask`时重载的`done`方法也就是Runnable执行完调用的方法中：

```
mFuture = new FutureTask<Result>(mWorker) {
            @Override
            protected void done() {
                try {
                    postResultIfNotInvoked(get());
                } catch (InterruptedException e) {
                    android.util.Log.w(LOG_TAG, e);
                } catch (ExecutionException e) {
                    throw new RuntimeException("An error occurred while executing doInBackground()",
                            e.getCause());
                } catch (CancellationException e) {
                    postResultIfNotInvoked(null);
                }
            }
        };

```

- 再看`MESSAGE_POST_PROGRESS`

```
    @WorkerThread
    protected final void publishProgress(Progress... values) {
        if (!isCancelled()) {
            getHandler().obtainMessage(MESSAGE_POST_PROGRESS,
                    new AsyncTaskResult<Progress>(this, values)).sendToTarget();
        }
    }

```

`publishProgress`方法是我们自己在`doInBackground`方法中手动调用的。

好了，到这里我们已经把整个流程和原理基本搞清楚了。

有一点我们知道，在Android 3.0以后`AsyncTask`默认是串行执行任务的，但是也可以选择`executeOnExecutor`方法来并行地执行任务。

AsyncTask在执行`execute`方法时默认采用的是`SerialExecutor`线程池，`SerialExecutor`线程池里维护了一个队列来保证任务是串行执行的。所以我们可以使用`executeOnExecutor`方法选择`THREAD_POOL_EXECUTE`来并行执行任务。

AsyncTask完！