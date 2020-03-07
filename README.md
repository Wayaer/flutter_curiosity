# flutter-curiosity
集成部分原生功能，支持ios&amp;android
计划完成功能

##1.打开闪光灯

##2.安装apk only Android

##3.跳转至应用商店 android ios

##4.解压文件

##5.二维码扫描
#### ios
##### 1、添加相机相关权限：

- 项目目录->Info.plist->增加

```
	<key>NSCameraUsageDescription</key>
	<string>扫描二维码时需要使用您的相机</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>扫描二维码时需要访问您的相册</string>
```
##6.图片选择
#### ios
##### 1、添加相册相关权限：

- 项目目录->Info.plist->增加

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
- 添加中文 PROJECT -> Info -> Localizations 点击"+"按钮，选择Chinese(Simplified)

##7.获取手机硬件信息 (app信息,手机厂商信息) 

