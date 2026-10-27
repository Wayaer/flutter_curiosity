# Curiosity

[flutter_curiosity](https://pub.dev/packages/flutter_curiosity) 的完整示例，单页中文界面，按平台能力展示全部功能：

- 系统能力：GPS 状态、键盘状态、退出应用。
- Android 专属：已安装应用、包信息、安装 APK、Activity 结果。
- 图片保存：保存图片字节、保存文件。

不支持的演示会显示当前平台说明，支持的演示才可交互。

## 运行

```bash
flutter pub get
flutter run
```

可选择已连接的 Android、iOS、macOS、Windows、Linux 或 Chrome 设备：

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d linux
```

Android、iOS 和 macOS 工程已使用 Flutter 3.47 重新生成，对应 AGP 9.1、Kotlin 2.4 和 Flutter 3.47
的 Xcode 模板。`ohos/` 目录保留给鸿蒙系统，需使用 OpenHarmony Flutter SDK 构建：

```bash
flutter build hap
```

## 平台说明

- Android 演示需要 `android/app/src/main/AndroidManifest.xml` 中声明的权限。
- iOS 保存图片需要 `NSPhotoLibraryAddUsageDescription`，已在 `Info.plist` 中配置。
- macOS 保存图片到“图片”文件夹，保存视频到“影片”文件夹；沙盒应用需要
  `com.apple.security.assets.pictures.read-write` 和 `com.apple.security.assets.movies.read-write` 权限，已配置。
- Web 端保存图片会触发浏览器下载，键盘状态使用 visual viewport。
- Windows 和 Linux 通过插件的 Dart 实现把图片保存到“图片”文件夹。
