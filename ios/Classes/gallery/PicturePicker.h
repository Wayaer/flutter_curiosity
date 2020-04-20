#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "TZImagePickerController.h"

@interface PicturePicker : NSObject <TZImagePickerControllerDelegate>
+ (void)openPicker:(NSDictionary*)arguments viewController:(UIViewController*)viewController result:(FlutterResult)result;
+ (void)openCamera:(NSDictionary*)arguments viewController:(UIViewController*)viewController result:(FlutterResult)result;
+ (void)deleteCacheDirFile;

@end
