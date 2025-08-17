## 6.9.0

* 支持 HarmonyOS

## 6.8.0

* Currently supports versions 3.27 to 3.35

## 6.7.0

* Added `addKeyboardListener`,`removeKeyboardListener` for  `NativeTools`
* Added `NativeKeyboardStatus`,`AndroidKeyboardParams`,`IOSKeyboardParams` for Native

## 6.6.0

* Migrate to 3.29.0
* Compatible with Android 35

## 6.4.0

* Add multiple themes for Android ,`BaseAppTheme` and `BaseNormalTheme`

## 6.3.1

* Update gradle version

## 6.2.0

* Added `ImageGalleryTools` for saving images to albums, supporting Android and iOS

## 6.1.0

* The call mode of `Curiosity()` is changed to `Curiosity.`

## 6.0.0

* Remove the DesktopTools

## 5.0.5

* `PackageInfoPlus` is changed to `PackageSelfInfo`

## 5.0.3

* Add `namespace` in Android

## 5.0.2

* Remove duplicate methods

## 4.5.0

* Remove `CuriosityEvent`
* Added [fl_channel](https://pub.dev/packages/fl_channel) plug-in

## 4.3.1

* dart sdk: '>=2.18.0 <4.0.0'

## 4.3.0

* Migrate MacOSWebView to [fl_webview](https://pub.dev/packages/fl_webview)

## 4.2.1

* Compatible with Flutter 3.7.0

## 4.0.1+1

* Compatible with flutter 3.0.0

## 3.5.1

* Add `generateDeviceId`、`deviceId` to The Android device for `DeviceInfoModel`
* Add Open webView for MacOS

## 3.3.3

* Fix bugs on MacOS
* Add the lowest version on ios and MacOS

## 3.3.2

* Add style `LaunchThemeFullscreenWhiteIcon`,`LaunchThemeFullscreenWhite`,
  `LaunchThemeFullscreenBlackIcon`,`LaunchThemeFullscreenBlack`,
  `LaunchThemeFullscreenIcon`,`LaunchThemeFullscreen`,`NormalTheme` for Android any picture
* Optimization method

## 3.3.0

* Remove instance , direct initialization

## 3.2.1

* Fix bugs for Android
* Update gradle version
* Update kotlin version

## 3.2.0

* Refactoring code in Native And dart
* Fix installApp bug in Android
* Fix desktop bug in MacOS

## 3.1.1

* Fix bug for DesktopSize
* Add `openFilePicker` and `saveFilePicker` methods for MacOS
* Add `openSystemSetting` for MacOS

## 3.0.1

* Add doc
* Add `getAppPath()`、`getDeviceInfo()` 、`getAppInfo()`  support Android/IOS/macOS
* Delete `ScannerView()` , Split to `fl_mlkit_scanning`(https://github.com/Wayaer/fl_mlkit_scanning)
* Remove `scanImageUrl()`、`scanImageMemory()`、
* Modifying swift by OC on IOS and MacOS platforms
* Add native message channel support Android and IOS .`CuriosityEvent`
* Remove `openSystemShare()`

## 2.2.1

* Add example
* Remove permissions in android/AndroidManifest.xml , you need to add them manually

## 2.2.0

* Add onResultListener to support onActivityResult and onRequestPermissionsResult on Android

## 2.1.2

* Fix bug for `systemCallPhone` in IOS

## 2.1.1

* Add systemCallPhone
* Remove goToMarker, add openAndroidMarket for Android
* Fix bugs for isInstallApp

## 2.0.9

* Fix bugs for desktop

## 2.0.6

* Fix bugs for Android `installApp`
* Add `InstallResult` enum

## 2.0.3

* Add void `keyboardListener`

## 2.0.2

* Add doc

## 2.0.1

* Add example

## 2.0.0

* Supported null-safety

## 1.6.0

* Optimize native Android & IOS

## 1.5.0

* Modify styles.dart
* the modification conflicts with the method of the camera component

## 1.3.6

* Remove TZImagePickerController and picture_library
* Remove openImagePicker
* Modify styles.dart
* the modification conflicts with the method of the camera component

## 1.3.3

* Code for Android to add jump settings
* Add get device information
* Example added

## 1.3.2

* Remove unzip
* Format code

## 1.2.4

* Fix scanner bug
* Add lint

## 1.2.2

* Fix bugs

## 1.2.1

* Refactoring all class and file names
* Optimization part code
* Add MacOS platform support

## 1.1.4

* After repairing the dispose component of scanner, the controller still holds the
* Fix the error of scanner component switching background and foreground

## 1.1.3

* Optimization class

## 1.1.0

* Scanner to replace texture components
* Optimize scan speed and accuracy
* Update picture selector version

## 0.0.1

* Create lib
