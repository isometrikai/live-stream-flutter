# Appscrip Chat Component

## Android

### Make these changes to your `AndroidMenifest.xml`

Path: `android` > `app` > `main` > `AndroidMenifest.xml`

1. Permissions

   ```xml
   <uses-feature android:name="android.hardware.camera" />
   <uses-feature android:name="android.hardware.camera.autofocus" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
   <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
   <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
   <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
   ```

1. To define a foreground service

   Add the following lines

   ```xml
   <application>
    ...
    <service
        android:name="de.julianassmann.flutter_background.IsolateHolderService"
        android:enabled="true"
        android:exported="false"
        android:foregroundServiceType="mediaProjection" />
     <activity
        android:name="com.yalantis.ucrop.UCropActivity"
        android:screenOrientation="portrait"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
    </application>
   ```

---

### Make these changes to your `build.gradle`

Path: `android` > `app` > `build.gradle`

1. Add versions inside android

   ```gradle
   android {
       compileSdkVersion 33

       defaultConfig {
           multiDexEnabled true
           minSdkVersion 24
       }
   }
   ```

2. Add multidex inside dependencies

   ```gradle
   dependencies {
       implementation 'com.android.support:multidex:1.0.3'
   }
   ```

---

### Make these changes in `gradle.properties`

```properties
android.useAndroidX=true
android.enableJetifier=true
```

Android Setup is done

Setup other platforms

- [iOS](./README_ios.md)
<!-- - [Web](./README_web.md) -->

[Go back to main](./README.md)
