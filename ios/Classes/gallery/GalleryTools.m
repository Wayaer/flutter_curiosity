#import "GalleryTools.h"

@implementation GalleryTools

// 打开相机
+ (void) openSystemCamera:(UIViewController *)viewController
                         :(UIImagePickerController *)picker
                         :(FlutterResult) result{
    picker.allowsEditing = YES; //可编辑
    //判断是否可以打开照相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        //摄像头
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [viewController presentViewController:picker animated:YES completion:nil];
    }else{
        result([Tools resultInfo:@"Can't open camera"]);
    }
}


// 打开相册
+ (void) openSystemGallery:(UIViewController *)viewController :(UIImagePickerController *)picker :(FlutterResult) result{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])  {
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [viewController presentViewController:picker animated:YES completion: nil];
    }else{
        result(@"fail,Can't open album");
    }
}

@end

