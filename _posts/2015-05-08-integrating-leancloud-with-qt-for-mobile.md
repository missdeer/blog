---
layout: post
author: missdeer
title: "Qt for Mobile集成LeanCloud"
categories: Qt
description: Qt for Mobile集成LeanCloud SDK
tags: Qt LeanCloud Mobile iOS Android
---
前些天想着给[istkani](https://itunes.apple.com/cn/app/istkani-le-tou-xing-cai-piao/id841279537)在Android集成个push notification，用了腾讯的[信鸽](http://xg.qq.com/)，结果在进程退出后老是会弹框说进程意外结束云云，于是就放下了。

后来又偶然地看了一下[LeanCloud](https://leancloud.cn/)，发现LeanCloud也是提供push服务的，于是就想再试试，顺便把它的其他能用上的功能都加上试试，于是就要集成它的iOS和Android的SDK，说干就干，现在终于初步已经完成了。

集成到Qt for iOS上相对来说要容易一些。

首先，自己重载一下`QIOSApplicationDelegate`：

```objective-c
#import <AVOSCloud/AVOSCloud.h>

@implementation QIOSApplicationDelegate (istkaniAppDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        //[application setMinimumBackgroundFetchInterval:minimumBackgroundFetchInterval];
    }
    
    // register for push notification
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {

        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert
                                                | UIUserNotificationTypeBadge
                                                | UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }else{
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert
                                                         | UIRemoteNotificationTypeSound
                                                         | UIRemoteNotificationTypeBadge)];
    }

    // launched by push notification
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"Remote notification payload at startup: %@", userInfo);
    [application setApplicationIconBadgeNumber:0];

    // leancloud initialize
    [AVOSCloud setApplicationId:@"xxxxxxxxxxxxxxxxxxxxxxxxxxx"
                  clientKey:@"yyyyyyyyyyyyyyyyyyyyyyyy"];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // register in leancloud
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation addUniqueObject:@"public" forKey:@"channels"];
    [currentInstallation saveInBackground];
}
```

然后，在qmake file里加上对LeanCloud SDK的链接：

```
ios {
    INCLUDEPATH += $$PWD/ios
    HEADERS += \
        $$PWD/ios/QtAppDelegate.h \
        $$PWD/ios/QtAppDelegate-C-Interface.h

    OBJECTIVE_SOURCES += \
        $$PWD/ios/QtAppDelegate.mm
        
    QMAKE_LFLAGS += -F$$PWD/avoscloud-ios-sdk-v3.1.1.1
    LIBS += -framework CFNetwork \
        -framework AVOSCloud  \
        -framework AVOSCloudCrashReporting \
        -framework AVOSCloudIM  \
        -framework AVOSCloudSNS  \
        -framework MobileCoreServices \
        -framework CoreTelephony \
        -framework CoreLocation \
        -licucore -lc++ -lz
}
```

这样就基本上搞定了。

----

在Android上集成稍微麻烦一点。我主要是要加入push notification，所以就冲着这个目标去了。

首先，重载`Application`类的`onCreate`方法：

```java
package com.dfordsoft.istkani;

import android.app.Application;
import org.qtproject.qt5.android.bindings.QtApplication;
import android.util.Log;
import com.avos.avoscloud.*;


public class IstkaniApp extends QtApplication {
    private final static String TAG = "istkani";

    @Override
    public void onCreate() {
        super.onCreate();
        AVOSCloud.initialize(this,
            "xxxxxxxxxxxxxxxxxxxxxxxxxxxx",
            "yyyyyyyyyyyyyyyyyyyyyyyyyyyy");

        // 设置默认打开的 Activity，注意，这里我把activity也派生了
        PushService.setDefaultPushCallback(this, QtPushActivity.class);
        // 订阅频道，当该频道消息到来的时候，打开对应的 Activity
        PushService.subscribe(this, "public", QtPushActivity.class);

        AVInstallation.getCurrentInstallation().saveInBackground(new SaveCallback() {
            public void done(AVException e) {
                if (e == null) {
                    // 保存成功
                    String installationId = AVInstallation.getCurrentInstallation().getInstallationId();
                    // 关联  installationId 到用户表等操作……
                    Log.d(TAG, "saved installation id:" + installationId);
                } else {
                    // 保存失败，输出错误信息
                    Log.w(TAG, "saving installation id failed");
                }

                AVInstallation.getCurrentInstallation().saveInBackground();
            }
        });

        // 启用崩溃错误统计
        AVAnalytics.enableCrashReport(this.getApplicationContext(), true);
        AVOSCloud.setDebugLogEnabled(true);

    }
}

```

另外，可以从默认的Activity类再派生一个类来做些其他事：

```java
package com.dfordsoft.istkani;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import com.avos.avoscloud.*;

public class QtPushActivity extends QtActivity {
    private final static String TAG = "istkani";

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "on destroy");
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "on create");
        AVAnalytics.trackAppOpened(getIntent());
    }

    protected void onPause() {
        super.onPause();
        AVAnalytics.onPause(this);
    }

    protected void onResume() {
        super.onResume();
        AVAnalytics.onResume(this);
    }
}

```

因为我的app包名是`com.dfordsoft.istkani`，所以这些Java源代码文件是要放在`$(PROJECT)/android/src/com/dfordsoft/istkani/`目录下的。把LeanCloud SDK中的那些jar文件放在`$(PROJECT)/android/libs`目录下。

然后修改qmake file：

```
android: {
    QT += androidextras
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += $$PWD/android/AndroidManifest.xml
    DISTFILES += \
        $$PWD/android/src/com/dfordsoft/istkani/QtPushActivity.java \
        $$PWD/android/src/com/dfordsoft/istkani/IstkaniApp.java
}
```

最后修改`AndroidManifest.xml`文件：

```xml
    <application android:name="com.dfordsoft.istkani.IstkaniApp" android:label="@string/app_name" android:icon="@drawable/icon">
        <activity android:screenOrientation="unspecified" android:name="com.dfordsoft.istkani.QtPushActivity" android:label="@string/app_name" android:configChanges="orientation|uiMode|screenLayout|screenSize|smallestScreenSize|locale|fontScale|keyboard|keyboardHidden|navigation">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <service android:name="com.avos.avoscloud.PushService" />

        <receiver android:name="com.avos.avoscloud.AVBroadcastReceiver" >
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.USER_PRESENT" />
            </intent-filter>
        </receiver>
    </application>
    <uses-sdk android:minSdkVersion="14" android:targetSdkVersion="21"/>
    <supports-screens android:normalScreens="true" android:smallScreens="true" android:largeScreens="true" android:anyDensity="true"/>
    <!-- %%INSERT_PERMISSIONS -->
    <!-- %%INSERT_FEATURES -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.WRITE_SETTINGS"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.READ_LOGS" />
```

这里为了让排版不那么乱，有一大堆`meta-data`节点没列出来，要改的是`application`节点的`android:name`属性是自己派生的`IstkaniApp`类，`activity`节点的`android:name`属性是自己派生的`QtPushActivity`类。另外就是加上必要的`service`节点，`receiver`节点和一些app必须的权限。

我试着加了其他的`AVDefaultNotificationReceiver`和自定义Receiver，结果在网络连接状态变化时，或者不能连网时，或者干脆在3G连接时，就会弹框报错，不知道信鸽是不是就是这个原因，我不也想再多追究了，好在这样就能正常收到push notification了。
