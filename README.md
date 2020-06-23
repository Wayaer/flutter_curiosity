# flutter_curiosity
集成部分原生功能，支持ios&amp;android

## 1.原生多个方法 [点击查看](./lib/tools/NativeTools.dart)

## 2.二维码扫描 [点击查看](./lib/scanner) 
```
   anroid 分 CameraX最新版预览识别 和旧版 Camera API预览识别
   新版API对于条形码的识别率 相对于 旧版的API正确率会低一些
   旧版不支持设置区域识别，新版 仅android支持指定区域识别
   打开闪光灯  android 暂时无效
```
##### 1、添加相机相关权限：

- 项目目录->Info.plist->增加

```
	<key>NSCameraUsageDescription</key>
	<string>扫描二维码时需要使用您的相机</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>扫描二维码时需要访问您的相册</string>
    <key>io.flutter.embedded_views_preview</key>
    <true/>
```
## 3.图片选择 [点击查看](./lib/gallery/PicturePicker.dart)
#### ios
##### 1、添加相册相关权限：

- 项目目录->Info.plist->增加
使用了相机、定位、麦克风、相册，请参考Demo添加下列属性到info.plist文件：

```
   <key>NSCameraUsageDescription</key>    
    <string>请允许打开相机拍照</string>
    <key>NSLocationWhenInUseUsageDescription</key>
	<string>我们需要通过您的地理位置信息获取您周边的相关数据</string>
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>请允许访问相册以选取照片</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>请允许访问相册以选取照片</string>
	<key>NSFileProviderDomainUsageDescription</key>
	<string>是否允许此App使用你的相机进行拍照？</string>
```

##### 2、中文适配：    
- 添加中文 Runner -> Info.plist -> Localizations 点击"+"按钮，选择Chinese(Simplified)

## 4.获取手机硬件信息 (app信息,手机厂商信息) [点击查看](./lib/app/AppInfo.dart)

