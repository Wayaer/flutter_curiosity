# flutter_curiosity

[Web example](https://wayaer.github.io/flutter_curiosity/example/app/web/index.html#/)

A Flutter plugin that integrates native and platform features for **Android**, **iOS**, **macOS**,
**HarmonyOS (OpenHarmony)**, **web**, **Windows** and **Linux**.

## Features

| Feature | Android | iOS | macOS | HarmonyOS | Web | Windows | Linux |
| --- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| GPS status | Yes | Yes | Yes | Yes | Permission | No | No |
| Keyboard status | Yes | Yes | No | Yes | Yes | No | No |
| Exit app | Yes | Yes | Yes | Yes | Best effort | Yes | Yes |
| Installed apps / package info | Yes | No | No | No | No | No | No |
| Install APK | Yes | No | No | No | No | No | No |
| Save image | Yes | Yes | Yes | Yes | Download | Yes | Yes |
| Activity result | Yes | No | No | No | No | No | No |

Notes:

- **Web**: GPS returns whether the browser geolocation permission is granted. Keyboard status uses the
  visual viewport. `ImageGalleryTools.saveBytesImage` downloads the bytes, `saveFilePath` is not supported,
  and `exitApp` only works for script-opened windows.
- **Windows / Linux**: Dart-only implementation. `exitApp` exits the process and `ImageGalleryTools` saves
  images to the Pictures folder and videos to the Videos folder. GPS and keyboard status are not supported.
- **macOS**: `ImageGalleryTools` saves images to the Pictures folder and videos to the Videos folder.
  Sandboxed apps need the Pictures and Movies read-write entitlements as described below.

## Installation

```yaml
dependencies:
  flutter_curiosity: ^8.0.0
```

The plugin supports both **Swift Package Manager** and **CocoaPods** on iOS and macOS. Flutter enables
Swift Package Manager by default since Flutter 3.24, and the plugin ships a `Package.swift` for both platforms.
iOS and macOS share a single Swift implementation under `darwin/`, so their Dart API and parameters are identical.

## Usage

```dart
import 'package:flutter_curiosity/flutter_curiosity.dart';

// Platform helpers.
final bool isAndroid = Curiosity.isAndroid;
final bool isHarmonyOS = Curiosity.isHarmonyOS;
final bool isWeb = Curiosity.isWeb;

// GPS status.
final bool gpsEnabled = await Curiosity.native.gpsStatus;

// Keyboard status.
void onKeyboardStatus(NativeKeyboardStatus status) {
  debugPrint('keyboard visible: ${status.visibility}, height: ${status.keyboardHeight}');
}

await Curiosity.native.addKeyboardListener(onKeyboardStatus);
await Curiosity.native.removeKeyboardListener(onKeyboardStatus);

// Android only.
final List<AppPackageInfo> apps = await Curiosity.native.getInstalledApps;
final AppPackageInfo? wechat = await Curiosity.native.getPackageInfo('com.tencent.mm');
final bool started = await Curiosity.native.installApk('/sdcard/Download/app.apk');

// Save an image: gallery on mobile, Pictures/Videos on macOS/Windows/Linux, download on web.
final bool savedBytes = await ImageGalleryTools.saveBytesImage(bytes, extension: ImageGalleryExtension.png);
final bool savedFile = await ImageGalleryTools.saveFilePath('/path/to/image.png');

// Exit the app.
await Curiosity.native.exitApp();
```

### Keyboard status

Use `NativeKeyboardStatusState` or `NativeKeyboardStatusMixin` to receive keyboard changes:

```dart
class _KeyboardPageState extends NativeKeyboardStatusState<KeyboardPage> {
  @override
  void onKeyboardListener(NativeKeyboardStatus params) {
    super.onKeyboardListener(params);
    setState(() {});
  }
}
```

### Activity result

```dart
class _PageState extends AndroidActivityResultState<Page> {
  @override
  void onAndroidActivityResult(AndroidActivityResult result) {
    super.onAndroidActivityResult(result);
    setState(() {});
  }
}
```

## Platform setup

### Android

The plugin merges a `FileProvider` and an HTTP network security config into your `AndroidManifest.xml`.
Add the permissions required by the features you use:

```xml
<!-- Install APK -->
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<!-- Installed apps / package info on Android 11+ -->
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
<!-- Saving to the gallery on Android 9 and below -->
<uses-permission
    android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="29" />
```

To look up a specific package with `getPackageInfo`, also declare it:

```xml
<queries>
  <package android:name="com.tencent.mm" />
</queries>
```

### iOS

Add the photo library usage description to `Info.plist` when using `ImageGalleryTools`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save images to your photo library.</string>
```

### macOS

`ImageGalleryTools` writes images to the Pictures folder and videos to the Videos folder. Sandboxed apps
need the Pictures and Movies read-write entitlements in both entitlement files:

```xml
<key>com.apple.security.assets.pictures.read-write</key>
<true/>
<key>com.apple.security.assets.movies.read-write</key>
<true/>
```

No photo library usage descriptions are required.

### HarmonyOS

The plugin includes an OpenHarmony implementation under `ohos/`. Build the app with the OpenHarmony
Flutter SDK (`flutter build hap`) and keep the generated `ohos/` directory of your app. Keyboard status,
GPS status, exit app and saving images to the gallery are supported.

### Web

No additional configuration is required. Keyboard status relies on the browser visual viewport, and
saving an image triggers a browser download. Browsers do not expose the GPS hardware state, so `gpsStatus`
returns whether the geolocation permission is already granted. Geolocation permission queries require a
secure context (HTTPS or localhost).

### Windows and Linux

The plugin is registered as a Dart-only plugin on Windows and Linux, so no native toolchain changes are
required. `exitApp` terminates the process, and `ImageGalleryTools` writes to the Pictures or Videos folder
of the current user. GPS status and keyboard status return `false` on these platforms.

## Example

A complete example is available in the [example](https://github.com/Wayaer/flutter_curiosity/tree/main/example)
directory with Android, iOS, macOS, web, Windows, Linux and HarmonyOS projects. The example is a
single-page Chinese UI that lists every feature and enables the demos supported by the current platform.

## License

MIT
