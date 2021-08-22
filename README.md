# flutter_curiosity

集成部分原生功能，支持 IOS Android macOS Windows Linux

### android

- 自动 添加 android http无法请求接口 解决方法
- 自动 添加 FileProvider 配置至 AndroidManifest
- 按需要 添加以下权限

```xml
<!--允许程序写入本地存储-->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
        <!--允许程序读取本地存储-->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
        <!--允许程序访问有关GSM网络信息-->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
        <!--允许程序安装应用程序-->
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>

```

### ios添加权限

* ios/Runner/Info.plist 按需要 添加权限

```plist
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
```

### 介绍

- 原生方法 [获取GPS状态、获取app本地储存路径、获取设备信息、获取app信息、打开系统设置]

```dart
void fun() {
  Curiosity.instance.native.fun();
}

```

- Android & IOS 原生摄像头 图库等相关功能

```dart
void gallery() {
  Curiosity.instance.gallery.fun();
}
```

- 消息通道

```dart
void fun() {
  Curiosity.instance.event.fun();
}
```

- 桌面端方法

```dart
void fun() {
  Curiosity.instance.desktop.fun();
}
```

- 桌面端窗口尺寸设置（支持 macOS Windows Linux）

```dart
void fun() {

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