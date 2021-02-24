# flutter_curiosity
集成部分原生功能，支持ios android

## ios添加权限
 * ios/Runner/Info.plist 添加权限
 
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