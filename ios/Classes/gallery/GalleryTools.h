#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "TZImagePickerController.h"
#import "Tools.h"

@interface GalleryTools : NSObject <TZImagePickerControllerDelegate>

+ (void)openImagePicker:(FlutterMethodCall*)call
                       :(UIViewController*)viewController
                       :(FlutterResult)result;

+ (void)deleteCacheDirFile:(FlutterResult)result;

//打开系统相册
+ (void)openSystemGallery:(UIViewController *)viewController
                         :(UIImagePickerController *)picker
                         :(FlutterResult) result;

//打开系统相机
+ (void)openSystemCamera:(UIViewController *)viewController
                        :(UIImagePickerController *)picker
                        :(FlutterResult) result;
@end
