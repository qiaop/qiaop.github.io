---
title: Android消息机制
date: 2017-03-13 20:12:45
tags:
- handler
categories:
- Android

---

有时候需要在子线程中进行耗时的I/O操作，当操作完成后可能需要在UI上做一些改变，由于Android开发规范的限制，我们并不能在主线程中访问UI控件，否则就会触发异常，这个时候通过Handler就可以将更新UI的操作切换到主线程中执行。

<!-- more -->
# 子线程为什么不能访问UI
因为Android的UI控件是线程安全的，如果在多线程中并发访问可能会导致UI空间处于不可预期的状态。
那为什么不对UI控件加上锁机制呢？

-  加上锁机制会让UI访问逻辑变得复杂；
-  锁机制会降低UI访问效率，因为锁机制会阻塞某些线程的执行。

# Android消息机制概述
Android消息机制主要是指Handler的运行机制，Handler的运行需要底层的MessageQueue和Looper的支撑。
## 消息机制的工作原理
Handler创建时会采用当前线程的Looper来构建内部的消息循环系统，如果当前线程没有Looper就会报错，我们经常提到的主线程也就是UI线程，它就是ActivityThread，ActivityThread被创建时就会初始化Looper，所以在主线程中默认可以使用Handler。


Handler创建完毕后，这个时候内部的Looper以及MessageQueue就可以和Handler一起协同工作了，然后通过Handler的send方法发送一个消息，它会调用MessageQueue的enqueueMessage方法将这个消息放入消息队列中，然后Looper发现有新消息到来时，就会处理这个消息，最终消息中的Runnable或者Handler的handleMessage方法就会被调用。

注意Looper是运行在创建Handler所在的线程中的，这样一来Handler中的业务逻辑就会被切换到创建Handler所在的线程中去执行了。

# Android消息机制分析
## ThreadLocal的工作原理
ThreadLocal并不是线程。它的作用是可以在线程中存储数据。ThreadLocal可以在不同的线程中互不干扰地存储并提供数据，通过ThreadLocal可以轻松获取每个线程的Looper。除了Looper，在ActivityThread以及AMS中都用到了ThreadLocal。

**通过ThreadLocal可以在不同线程中维护一套数据的副本并且彼此互不干扰。**

_这是因为不同线程访问同一个ThreadLocal的get方法，ThreadLocal内部会从各自的线程中取出一个数组，然后再从数组中根据当前Thread的索引去查找出对应的value值。_

从ThreadLocal的set和get方法可以看出，它们所操作的对象都是当前线程的localValues对象的table数组，因此在不同线程中访问同一个ThreadLocal的set和get方法，它们对ThreadLocal所做的读/写操作仅限于各自的线程内部。

## MessageQueue消息队列的工作原理
消息队列在Android中指的是MessageQueue，包含两个操作：插入和读取。读取操作本身伴随着删除的操作。


```

enqueueMessage 往消息队列中插入一条消息

next 从消息队列中取出一条消息并将其从消息队列中移除
```
MessageQueue实际上是通过一个单链表的数据结构来维护消息列表，单链表在插入和删除上比较有优势。

enqueueMessage源码：

```java
boolean enqueueMessage(Message msg, long when) {
   if (msg.target == null) {
       throw new IllegalArgumentException("Message must have a target.");
   }
   if (msg.isInUse()) {
       throw new IllegalStateException(msg + " This message is already in use.");
   }
   synchronized (this) {
       if (mQuitting) {
           IllegalStateException e = new IllegalStateException(
                   msg.target + " sending message to a Handler on a dead thread");
           Log.w(TAG, e.getMessage(), e);
           msg.recycle();
           return false;
       }
       msg.markInUse();
       msg.when = when;
       Message p = mMessages;
       boolean needWake;
       if (p == null || when == 0 || when < p.when) {
           // New head, wake up the event queue if blocked.
           msg.next = p;
           mMessages = msg;
           needWake = mBlocked;
       } else {
           // Inserted within the middle of the queue.  Usually we don't have to wake
           // up the event queue unless there is a barrier at the head of the queue
           // and the message is the earliest asynchronous message in the queue.
           needWake = mBlocked && p.target == null && msg.isAsynchronous();
           Message prev;
           for (;;) {
               prev = p;
               p = p.next;
               if (p == null || when < p.when) {
                   break;
               }
               if (needWake && p.isAsynchronous()) {
                   needWake = false;
               }
           }
           msg.next = p; // invariant: p == prev.next
           prev.next = msg;
       }
       // We can assume mPtr != 0 because mQuitting is false.
       if (needWake) {
           nativeWake(mPtr);
       }
   }
   return true;
}

```
从源码来看主要操作就是单链表的插入操作。

next方法的源码：

```java
Message next() {
   // Return here if the message loop has already quit and been disposed.
   // This can happen if the application tries to restart a looper after quit
   // which is not supported.
   final long ptr = mPtr;  //mPrt是native层的MessageQueue的指针
   if (ptr == 0) {
       return null;
   }
   int pendingIdleHandlerCount = -1; // -1 only during first iteration
   int nextPollTimeoutMillis = 0;
   for (;;) {
       if (nextPollTimeoutMillis != 0) {
           Binder.flushPendingCommands();
       }
       nativePollOnce(ptr, nextPollTimeoutMillis); // jni函数
       synchronized (this) {
           // Try to retrieve the next message.  Return if found.
           final long now = SystemClock.uptimeMillis();
           Message prevMsg = null;
           Message msg = mMessages;
           if (msg != null && msg.target == null) { //target 正常情况下都不会为null，在postBarrier会出现target为null的Message
               // Stalled by a barrier.  Find the next asynchronous message in the queue.
               do {
                   prevMsg = msg;
                   msg = msg.next;
               } while (msg != null && !msg.isAsynchronous());
           }
           if (msg != null) {
               if (now < msg.when) {
                   // Next message is not ready.  Set a timeout to wake up when it is ready.
                   nextPollTimeoutMillis = (int) Math.min(msg.when - now, Integer.MAX_VALUE);
               } else {
                   // Got a message.
                   mBlocked = false;
                   if (prevMsg != null) {
                       prevMsg.next = msg.next;
                   } else {
                       mMessages = msg.next;
                   }
                   msg.next = null;
                   if (DEBUG) Log.v(TAG, "Returning message: " + msg);
                   msg.markInUse();
                   return msg;
               }
           } else {
               // No more messages.
               nextPollTimeoutMillis = -1; // 等待时间无限长
           }
           // Process the quit message now that all pending messages have been handled.
           if (mQuitting) {
               dispose();
               return null;
           }
           // If first time idle, then get the number of idlers to run.
           // Idle handles only run if the queue is empty or if the first message
           // in the queue (possibly a barrier) is due to be handled in the future.
           if (pendingIdleHandlerCount < 0
                   && (mMessages == null || now < mMessages.when)) {
               pendingIdleHandlerCount = mIdleHandlers.size();
           }
           if (pendingIdleHandlerCount <= 0) {
               // No idle handlers to run.  Loop and wait some more.
               mBlocked = true;
               continue;
           }
           if (mPendingIdleHandlers == null) {
               mPendingIdleHandlers = new IdleHandler[Math.max(pendingIdleHandlerCount, 4)];
           }
           mPendingIdleHandlers = mIdleHandlers.toArray(mPendingIdleHandlers);
       }
       // Run the idle handlers.
       // We only ever reach this code block during the first iteration.
       for (int i = 0; i < pendingIdleHandlerCount; i++) { //运行idle
           final IdleHandler idler = mPendingIdleHandlers[i];
           mPendingIdleHandlers[i] = null; // release the reference to the handler
           boolean keep = false;
           try {
               keep = idler.queueIdle();
           } catch (Throwable t) {
               Log.wtf(TAG, "IdleHandler threw exception", t);
           }
           if (!keep) {
               synchronized (this) {
                   mIdleHandlers.remove(idler);
               }
           }
       }
       // Reset the idle handler count to 0 so we do not run them again.
       pendingIdleHandlerCount = 0;
       // While calling an idle handler, a new message could have been delivered
       // so go back and look again for a pending message without waiting.
       nextPollTimeoutMillis = 0;
   }
}

```
**next方法是一个无线循环的方法，如果消息队列中没有消息，那么next方法会一直阻塞在这里，当新消息到来时，enqueue这边唤醒会next方法，next方法会返回这条消息并将其从单链表中移除。**

## Looper的工作原理

**Looper会不停地从MessageQueue中查看是否有新消息，如果有会立刻处理，否则会一直阻塞。**

Looper的构造方法：

```java
    private Looper(boolean quitAllowed) {
        mQueue = new MessageQueue(quitAllowed);
        mThread = Thread.currentThread();
    }
```
在构造方法中会创建一个MessageQueue，然后将当前线程的对象保存起来。

Handler的工作需要Looper，没有Looper的线程就会报错，通过Looper.prepare()即可为当前线程创建一个Looper，接着通过Looper.loop()来开启消息循环。

Looper还提供了prepareMainLooper方法，这个方法主要是给主线程（ActivityThread）创建Looper使用的，本质也是通过prepare方法实现的。通过getMainLooper方法可以在任何地方获取到主线程的Looper。

Looper提供quit和quitSafely来退出一个Looper,退出后Handler发送消息会失败。

```
quit会直接退出Looper
quitSafely会设定一个退出标记，等消息队列中的消息处理完毕后才安全地退出。
```
**在子线程中如果手动创建了Looper，那么在所有的事情完成以后应该调用quit方法来终止消息循环，线程会立刻中介，否则子线程会一直处于等待的状态。**

Looper最重要的一个方法是loop，只有调用loop后消息循环系统才会真正地起作用。

```java
public static void loop() {
   final Looper me = myLooper();
   if (me == null) {
       throw new RuntimeException("No Looper; Looper.prepare() wasn't called on this thread.");
   }
   final MessageQueue queue = me.mQueue;
   // Make sure the identity of this thread is that of the local process,
   // and keep track of what that identity token actually is.
   Binder.clearCallingIdentity();
   final long ident = Binder.clearCallingIdentity();
   for (;;) {
       Message msg = queue.next(); // might block 此处就是next方法调用的地方
       if (msg == null) {
           // No message indicates that the message queue is quitting.
           return;
       }
       // This must be in a local variable, in case a UI event sets the logger
       Printer logging = me.mLogging;
       if (logging != null) {
           logging.println(">>>>> Dispatching to " + msg.target + " " +
                   msg.callback + ": " + msg.what);
       }
       msg.target.dispatchMessage(msg);
       if (logging != null) {
           logging.println("<<<<< Finished to " + msg.target + " " + msg.callback);
       }
       // Make sure that during the course of dispatching the
       // identity of the thread wasn't corrupted.
       final long newIdent = Binder.clearCallingIdentity();
       if (ident != newIdent) {
           Log.wtf(TAG, "Thread identity changed from 0x"
                   + Long.toHexString(ident) + " to 0x"
                   + Long.toHexString(newIdent) + " while dispatching to "
                   + msg.target.getClass().getName() + " "
                   + msg.callback + " what=" + msg.what);
       }
       msg.recycleUnchecked();
   }
}

```
整个loop函数大概的过程就是先调用MessageQueue.next方法获取一个Message，然后调用Message的target的dispatchMessage方法来处理Message，Message的target就是发送这个Message的Handler。

处理的过程是先看Message的callback有没有实现，如果有，则使用调用callback的run方法，如果没有则看Handler的callback是否为空，如果非空，则使用handler的callback的handleMessage方法来处理Message，如果为空，则调用Handler的handleMessage方法处理.

当MessageQueue的next方法返回为null的时候，loop就结束了循环。quit和quitSafely方法来通知消息队列退出时它的next方法就会返回为null。

## Handler的工作原理

Handler主要包含消息的发送和接收过程。

消息的发送有post方式和send方式，都是通过send的一系列方法来实现的。最终是向消息队列中插入了一条消息。

```java
private boolean enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis) {
        msg.target = this;
        if (mAsynchronous) {
            msg.setAsynchronous(true);
        }
        return queue.enqueueMessage(msg, uptimeMillis);
    }

```

插入消息后MessageQueue的next方法就会返回这条消息给Looper，消息最终由Looper交给Handler处理，Handler的dispathMessage方法会被调用。

```java
    public void dispatchMessage(Message msg) {
        if (msg.callback != null) {
            handleCallback(msg);
        } else {
            if (mCallback != null) {
                if (mCallback.handleMessage(msg)) {
                    return;
                }
            }
            handleMessage(msg);
        }
    }

```
首先检查Message的callback
是否为null，不为null就通过handleCallback来处理消息。Message的callback是一个Runnable对象，实际就是Handler的post方法所传递的Runnable参数。

其次，检查mCallback是否为null，不为null就调用mCallback的handleMessage方法来处理消息。Callback是个接口：

```java
  /**
     * Callback interface you can use when instantiating a Handler to avoid
     * having to implement your own subclass of Handler.
     *
     * @param msg A {@link android.os.Message Message} object
     * @return True if no further handling is desired
     */
    public interface Callback {
        public boolean handleMessage(Message msg);
    }

```

通过Callback可以采用Handler handler = new Handler(callback)。的方式创建Handler对象。

最后调用Handler的handleMessage方法来处理消息。

## 主线程的消息循环模型

Android主线程就是ActivityThread，主线程的入口方法为main，在main方法中系统会通过Looper.prepareMainLooper()来创建主线程的Looper以及MessageQueue，并通过Looper.loop()来开启主线程的消息循环。

主线程消息循环开始了以后，ActivityThread还需要一个Handler来和消息队列进行交互，这个Handler就是ActivityThread.H，它内部定义了一组消息类型，主要包含了四大组件的启动和停止等过程。

ActivityThread通过ApplicationThread和AMS进行进程间通信，AMS以进程间通信的方式完成ActivityThread的请求后会回调ApplicationThread中的Binder方法，然后ApplicationThread会向H发送消息，H收到消息后会将ApplicationThread中的逻辑切换到ActivityThread中去执行，即切换到主线程中去执行，这个过程就是主线程的消息循环模型。