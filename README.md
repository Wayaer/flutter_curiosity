# flutter_curiosity
集成部分原生功能，支持ios android

## android
1.自动 添加 android http无法请求接口 解决方法
2.自动 添加 FileProvider 配置至 AndroidManifest
3.按需要 添加以下权限
```xml
      <!--允许程序打开网络-->
      <uses-permission android:name="android.permission.INTERNET" />
      <!--允许程序使用相机-->
      <uses-permission android:name="android.permission.CAMERA" />
      <!--允许程序写入本地存储-->
      <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
      <!--允许程序读取本地存储-->
      <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
      <!--允许程序打开闪光灯-->
      <uses-permission android:name="android.permission.FLASHLIGHT" />
      <!--允许程序访问有关GSM网络信息-->
      <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
      <!--允许程序防止休眠-->
      <uses-permission android:name="android.permission.WAKE_LOCK" />
      <!--允许程序拨打电话-->
      <uses-permission android:name="android.permission.CALL_PHONE" />
      <!--允许程序安装应用程序-->
      <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

```

## ios添加权限
 * ios/Runner/Info.plist 按需要 添加权限
 
```
    <key>NSCameraUsageDescription</key>    
    <string>请允许打开相机拍照</string>
    <key>NSLocationWhenInUseUsageDescription</key>
	<string>通过您的地理位置信息获取您周边的相关数据</string>
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>请允许访问相册以选取照片</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>请允许访问相册以选取照片</string>
	<key>NSFileProviderDomainUsageDescription</key>
	<string>是否允许此App使用你的相机进行拍照？</string>
    <key>io.flutter.embedded_views_preview</key>
    <true/>
```

### 1.[原生方法](./lib/tools/native.dart)

### 2.[二维码扫描](./lib/scanner)

### 3.获取手机硬件信息 (app信息,设备信息)
<img src="example/screen/main.png" width="360px"/> <img src="example/screen/share.png" width="360px"/>
<img src="example/screen/android_setting.png" width="360px"/> <img src="example/screen/app_device.png" width="360px"/>
<img src="example/screen/camera_gallry.png" width="360px"/>

### 4.键盘状态监听
```dart

    @override
    void initState() {
      super.initState();
      keyboardListener((bool visibility) {
        log(visibility);
        showToast(visibility ? '键盘已弹出' : '键盘已关闭');
      });
    }

```
### 5.原生回调
```dart
  @override
  void initState() {
    super.initState();
    if (isMobile) {
      log('添加 原生回调监听');
      onResultListener(activityResult: (AndroidActivityResult result) {
        log('AndroidResult requestCode = ${result.requestCode}  '
            'resultCode = ${result.resultCode}  data = ${result.data}');
      }, requestPermissionsResult: (AndroidRequestPermissionsResult result) {
        log('AndroidRequestPermissionsResult: requestCode = ${result.requestCode}  \n'
            ' permissions = ${result.permissions} \n grantResults = ${result.grantResults}');
      });
    }
  }


```

## 桌面端窗口尺寸设置（支持 macOS windows linux）
```dart
void fun(){ 
  
     getDesktopWindowSize();

     setDesktopWindowSize();

     setDesktopMinWindowSize();

     setDesktopMaxWindowSize();

     resetDesktopMaxWindowSize();

     toggleDesktopFullScreen();

     setDesktopFullScreen();

     getDesktopFullScreen();

     /// 设置桌面版 为 手机 或 ipad 尺寸
     setDesktopSizeTo4P7();

     setDesktopSizeTo5P5();

     setDesktopSizeTo5P8();

     setDesktopSizeTo6P1();

     setDesktopSizeToIPad11();

     setDesktopSizeToIPad10P5();

     setDesktopSizeToIPad9P7();

}
```