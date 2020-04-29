#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "TZImagePickerController.h"

@interface PicturePicker : NSObject <TZImagePickerControllerDelegate>
+ (void)openPicker:(FlutterMethodCall*)call viewController:(UIViewController*)viewController result:(FlutterResult)result;
+ (void)openCamera:(UIViewController*)viewController result:(FlutterResult)result;
+ (void)deleteCacheDirFile;

@end
