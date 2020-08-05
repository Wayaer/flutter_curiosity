#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "TZImagePickerController.h"

@interface PicturePicker : NSObject <TZImagePickerControllerDelegate>
+ (void)openImagePicker:(FlutterMethodCall*)call :(UIViewController*)viewController :(FlutterResult)result;

+ (void)openCamera:(UIViewController*)viewController :(UIImagePickerController *)picker :(FlutterResult)result;

+ (void)deleteCacheDirFile:(FlutterResult)result;

@end
