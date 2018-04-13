---
title: android 应用中多个fileprovider处理
date: 2018-02-07 17:11:41
tags: 7.0
categories:
- Android

---
## 引言
Android 7.0 提供了很多变化，Android 框架执行的 StrictMode API 政策禁止在应用外部公开 file:// URI。如果一项包含文件 URI 的 intent 离开您的应用，则应用出现故障，并出现 FileUriExposedException 异常。

要在应用间共享文件，您应发送一项 content:// URI，并授予 URI 临时访问权限。进行此授权的最简单方式是使用 FileProvider 类。

**在对项目进行适配的时候，发现有多个地方需要用到FileProvider，例如拍照功能，apk安装功能，我们可以选择使用一套，但有时候必须得提供两个或者多个FileProvider来解决**

## 问题
在使用多个FileProvider时，不能每个都直接使用`android.support.v4.content.FileProvider`

<!-- more -->

```xml
<provider
            android:name="android.support.v4.content.FileProvider"
            android:authorities="xx.xx.xxx.fileprovider"
            android:grantUriPermissions="true"
            android:exported="false">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/filepaths" />
        </provider>

```

## 解决
1. 新建类继承 MyFileProvider extends `android.support.v4.content.FileProvider`,
2. 在manifest文件中添加provider，`android:name`值设置为第一步新建的类：

	```xml
	<provider
            android:authorities="com.xx.xxx.provider"
            android:name="com.xx.xxx.MyFileProvider"
            android:grantUriPermissions="true"
            android:exported="false">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/filepaths"/>
        </provider>
	
	```
3. 其余步骤没有区别，新建res/xml/filepaths.xml,设置path。

	```
	<root-path/> 代表设备的根目录new File("/");
	<files-path/> 代表context.getFilesDir()
	<cache-path/> 代表context.getCacheDir()
	<external-path/> 代表Environment.getExternalStorageDirectory()
	<external-files-path>代表context.getExternalFilesDirs()
	<external-cache-path>代表getExternalCacheDirs()
	```
## 附
下载apk至Download目录并安装部分代码

**自定义FileProvider**

```java
public class FileProvider extends android.support.v4.content.FileProvider {
}

```
**res/xml/fiflepaths.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-files-path name="Download" path="Download"/>
</paths>

```

**manifest.xml**

```xml
<provider
            android:authorities="com.xx.xxx.provider"
            android:name="com.xx.xxx.FileProvider"
            android:grantUriPermissions="true"
            android:exported="false">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/filepaths"/>
        </provider>

```
**下载完成安装apk**

```java
    @Override
    public void onReceive(Context context, Intent intent) {
        if (DownloadManager.ACTION_DOWNLOAD_COMPLETE.equals(intent.getAction())) {
            long id = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, 0);
            long refId=DownloadFileRef.getRef(context);
            if(id==refId&&refId!=-1){
                installApk(context, getApkPath(context, id));
             }
        }
    }

```


```java
	private Uri getApkPath(Context context, long id) {
	        Uri uri =null;
	        DownloadManager manager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
	        Cursor c = manager.query(new DownloadManager.Query().setFilterById(id));
	        if(c.moveToFirst()){
	            String uriStr = c.getString(c.getColumnIndex(DownloadManager.COLUMN_LOCAL_URI));
	            if(!TextUtils.isEmpty(uriStr)){
	                uri = Uri.parse(uriStr);
	            }
	        }
	        return uri;
	    }

```

```java
    private void installApk(Context context, Uri path) {
        if (path!=null) {
            File file = new File(path.getPath());
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            if (Build.VERSION.SDK_INT>=24){
                Uri apkUri = FileProvider.getUriForFile(context,"com.xx.xxx.provider",file);
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
            }else{
                intent.setDataAndType(path, "application/vnd.android.package-archive");
            }
            context.startActivity(intent);
        }
    }

```