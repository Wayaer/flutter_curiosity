# flutter_curiosity

## 集成部分原生功能，支持 IOS Android macOS Windows Linux

### android

- 自动 添加 android http无法请求接口 解决方法
- 自动 添加 FileProvider 配置至 AndroidManifest
- 按需要 添加以下权限

```html
<!--允许程序安装应用程序 可选-->
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>

```

### 介绍

- 原生方法 [获取GPS状态、获取app信息、监听键盘状态、获取android已安装应用、监听android activity result]

```dart
void fun() {
  Curiosity().native.fun();
}

```

- 桌面端方法

```dart
void fun() {
  Curiosity().desktop.fun();
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