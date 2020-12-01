#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "Tools.h"

@interface GalleryTools : NSObject

//打开系统相册
+ (void)openSystemGallery:(UIViewController *)viewController
                         :(UIImagePickerController *)picker
                         :(FlutterResult) result;

//打开系统相机
+ (void)openSystemCamera:(UIViewController *)viewController
                        :(UIImagePickerController *)picker
                        :(FlutterResult) result;
@end
