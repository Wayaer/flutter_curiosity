## 3.5.0

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

## 2.2.3

* Add `setDesktopSizeToIPad11()`、`setDesktopSizeToIPad10P5()`、`setDesktopSizeToIPad9P7()`

## 2.2.2

* Fix Windows/Linux unable to add dependency

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