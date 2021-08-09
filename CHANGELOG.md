## [3.1.1]
 * fix bug for DesktopSize
## [3.1.0]
 * add [openFilePicker] and [saveFilePicker] methods for MacOS
 * add [openSystemSetting] for MacOS
## [3.0.1]
 * add doc
 * add [getAppPath()]、[getDeviceInfo()] 、[getAppInfo()]  support Android/IOS/macOS
 * delete [ScannerView()] , Split to [fl_mlkit_scanning](https://github.com/Wayaer/fl_mlkit_scanning)
 * remove [scanImageUrl()]、[scanImageMemory()]、
 * modifying swift by OC on IOS and MacOS platforms
 * add native message channel support Android and IOS .[CuriosityEvent]
 * remove [openSystemShare()]
## [2.2.3]
 * add [setDesktopSizeToIPad11()]、[setDesktopSizeToIPad10P5()]、[setDesktopSizeToIPad9P7()]
## [2.2.2]
 * fix Windows/Linux unable to add dependency
## [2.2.1]
 * add example
 * remove permissions in android/AndroidManifest.xml , you need to add them manually
## [2.2.0]
 * add onResultListener to support onActivityResult and onRequestPermissionsResult on Android
## [2.1.2]
 * fix bug for [systemCallPhone] in IOS
## [2.1.1]
 * add systemCallPhone 
 * remove goToMarker, add openAndroidMarket for Android
 * fix bugs for isInstallApp
## [2.0.9]
 * fix bugs for desktop
## [2.0.6]
 * fix bugs for Android [installApp]
 * add [InstallResult] enum
## [2.0.3]
 * add void [keyboardListener]
## [2.0.2]
 * add doc
## [2.0.1]
 * add example
## [2.0.0]
 * Supported null-safety
## [1.6.0]
 * Optimize native Android & IOS
## [1.5.0]
 * modify styles.dart
 * the modification conflicts with the method of the camera component
## [1.3.6]
 * remove TZImagePickerController and picture_library
 * remove openImagePicker
 * modify styles.dart
 * the modification conflicts with the method of the camera component
## [1.3.3]
 * Code for Android to add jump settings
 * Add get device information
 * Example added
## [1.3.2]
 * remove unzip
 * format code
## [1.2.4]
 * fix scanner bug
 * add lint
## [1.2.2]
 * Fix bugs
## [1.2.1]
 * Refactoring all class and file names
 * Optimization part code
 * Add MacOS platform support
## [1.1.4]
 * After repairing the dispose component of scanner, the controller still holds the
 * Fix the error of scanner component switching background and foreground
## [1.1.3]
 * Optimization class
## [1.1.0]
 * Scanner to replace texture components
 * Optimize scan speed and accuracy
 * Update picture selector version
## [0.0.1]
 *  create lib