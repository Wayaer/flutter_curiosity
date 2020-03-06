#import "PicturePicker.h"

#import "TZImageManager.h"
#import "TZImageCropManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface PicturePicker ()

@property (nonatomic, strong) UIImagePickerController *picker;

@end
@implementation PicturePicker

+ (void)openSelect:(NSDictionary *)arguments viewController:(UIViewController*)viewController {
    
     NSLog(@"LogInfo%@",arguments);
     NSLog(@"LogInfo%@",viewController);
    int maxSelectNum = [[arguments objectForKey:@"maxSelectNum"] intValue];
    int minSelectNum = [[arguments objectForKey:@"minSelectNum"] intValue];
    //    int imageSpanCount = [[arguments objectForKey:@"imageSpanCount"] intValue];
    int selectionMode = [[arguments objectForKey:@"selectionMode"] intValue];
    //    int minimumCompressSize = [[arguments objectForKey:@"minimumCompressSize"] intValue];
    int cropW = [[arguments objectForKey:@"cropW"] intValue];
    int cropH = [[arguments objectForKey:@"cropH"] intValue];
        int cropCompressQuality = [[arguments objectForKey:@"cropCompressQuality"] intValue];
    int videoMaxSecond = [[arguments objectForKey:@"videoMaxSecond"] intValue];
    //    int videoMinSecond = [[arguments objectForKey:@"videoMinSecond"] intValue];
    //    int recordVideoSecond = [[arguments objectForKey:@"recordVideoSecond"] intValue];
    int pickerSelectType = [[arguments objectForKey:@"pickerSelectType"] intValue];
    int circleCropRadius = [[arguments objectForKey:@"circleCropRadius"] intValue];
    BOOL previewImage = [[arguments objectForKey:@"previewImage"] boolValue];
    //    BOOL previewVideo = [[arguments objectForKey:@"previewVideo"] boolValue];
    //    BOOL isZoomAnim = [[arguments objectForKey:@"isZoomAnim"] boolValue];
    BOOL isCamera = [[arguments objectForKey:@"isCamera"] boolValue];
    BOOL enableCrop = [[arguments objectForKey:@"enableCrop"] boolValue];
    //    BOOL compress = [[arguments objectForKey:@"compress"] boolValue];
    //    BOOL hideBottomControls = [[arguments objectForKey:@"hideBottomControls"] boolValue];
    //    BOOL freeStyleCropEnabled = [[arguments objectForKey:@"freeStyleCropEnabled"] boolValue];
    BOOL showCropCircle = [[arguments objectForKey:@"showCropCircle"] boolValue];
    //    BOOL showCropFrame = [[arguments objectForKey:@"showCropFrame"] boolValue];
    //    BOOL showCropGrid = [[arguments objectForKey:@"showCropGrid"] boolValue];
    //    BOOL openClickSound = [[arguments objectForKey:@"openClickSound"] boolValue];
    BOOL isGif = [[arguments objectForKey:@"isGif"] boolValue];
    BOOL scaleAspectFillCrop = [[arguments objectForKey:@"scaleAspectFillCrop"] boolValue];
    BOOL originalPhoto = [[arguments objectForKey:@"originalPhoto"] boolValue];
    
    TZImagePickerController *picker = [[TZImagePickerController alloc] initWithMaxImagesCount:maxSelectNum delegate:nil];
    picker.maxImagesCount=maxSelectNum;
    picker.minImagesCount=minSelectNum;
    picker.allowPickingGif=isGif;
    picker.allowCrop=enableCrop;
    if(pickerSelectType==1){
        picker.allowPickingImage=true;
        picker.allowTakePicture=isCamera;
        picker.allowPickingVideo=false;
        picker.allowTakeVideo=false;
    }else if(pickerSelectType==2){
        picker.allowPickingVideo=true;
        picker.allowTakeVideo=isCamera;
        picker.allowPickingImage=false;
        picker.allowTakePicture=false;
    }else{
        picker.allowPickingImage=true;
        picker.allowPickingVideo=true;
        picker.allowTakePicture=isCamera;
        picker.allowTakeVideo=isCamera;
        
    }
    if (isCamera&&picker.allowTakeVideo) {
        picker.videoMaximumDuration=videoMaxSecond;
    }
    picker.allowPreview=previewImage;
    picker.allowPickingOriginalPhoto=originalPhoto;
    picker.showPhotoCannotSelectLayer=true;
  
    if (selectionMode == 1) {  // 单选模式
        picker.showSelectBtn = NO;
        picker.allowCrop=enableCrop;
        if(enableCrop){
            picker.scaleAspectFillCrop=scaleAspectFillCrop;//是否图片等比缩放填充cropRect区域
            if(showCropCircle) {
                picker.needCircleCrop = showCropCircle; //圆形裁剪
                picker.circleCropRadius = circleCropRadius; //圆形半径
            } else {
                CGFloat x = ([[UIScreen mainScreen] bounds].size.width - cropW) / 2;
                CGFloat y = ([[UIScreen mainScreen] bounds].size.height - cropH) / 2;
                picker.cropRect = CGRectMake(x,y,cropW,cropH);
            }
        }
    }
    __weak TZImagePickerController *weakPicker = picker;
    [picker setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
         [weakPicker showProgressHUD];
          NSLog(@"LogInfo%@",assets);
        if (maxSelectNum == 1 && enableCrop) {
               [self cropImage:photos[0] asset:assets[0] quality:cropCompressQuality];
            }
//        else {
//                [infos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    [self handleAssets:assets photos:photos quality:quality isSelectOriginalPhoto:isSelectOriginalPhoto completion:^(NSArray *selecteds) {
//                      return selecteds;
//                    } fail:^(NSError *error) {
//
//                    }];
//                }];
//            }
         [weakPicker hideProgressHUD];
    }];
//    [picker setImagePickerControllerDidCancelHandle:^{
//     NSLog(@"LogInfo%@",@"cancel");
//        [weakPicker hideProgressHUD];
//    }];
//    [picker setDidFinishPickingGifImageHandle:^(UIImage *animatedImage, id sourceAssets) {
//           NSLog(@"LogInfo%@",sourceAssets);
//    }];
    [picker setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
        //
           NSLog(@"LogInfo%@",assets);
    }];


    [viewController presentViewController:picker animated:YES completion:nil];
}
//+ (UIViewController *)viewController {
//    UIViewController *rootViewController = FlutterViewController();
//    return rootViewController;
//}

+ (void)openCamera:(NSDictionary *)arguments{
    NSLog(@"LogInfo%@",arguments);
    
}
+ (void)deleteCacheDirFile{
    
    
    
}

// 裁剪图片
+ (NSDictionary *)cropImage:(UIImage *)image asset:(PHAsset *)asset quality:(CGFloat)quality {
    [self createCache];
    NSMutableDictionary *photo  = [NSMutableDictionary dictionary];
    NSString *filename = [NSString stringWithFormat:@"%@%@", [[NSUUID UUID] UUIDString], [asset valueForKey:@"filename"]];
    NSString *fileExtension    = [filename pathExtension];
    NSMutableString *filePath = [NSMutableString string];
    BOOL isPNG = [fileExtension hasSuffix:@"PNG"] || [fileExtension hasSuffix:@"png"];

    if (isPNG) {
        [filePath appendString:[NSString stringWithFormat:@"%@PicturePickerCaches/%@", NSTemporaryDirectory(), filename]];
    } else {
        [filePath appendString:[NSString stringWithFormat:@"%@PicturePickerCaches/%@.jpg", NSTemporaryDirectory(), [filename stringByDeletingPathExtension]]];
    }

    NSData *writeData = isPNG ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, quality/100);
    [writeData writeToFile:filePath atomically:YES];

    photo[@"path"]       = filePath;
    photo[@"width"]     = @(image.size.width);
    photo[@"height"]    = @(image.size.height);
    NSInteger size = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize;
    photo[@"size"] = @(size);
    return photo;
}
/// 视频数据
- (NSDictionary *)videoAsset:(NSString *)outputPath asset:(PHAsset *)asset coverImage:(UIImage *)coverImage quality:(CGFloat)quality {
    NSMutableDictionary *video = [NSMutableDictionary dictionary];
    video[@"path"] = outputPath;
    NSInteger size = [[NSFileManager defaultManager] attributesOfItemAtPath:outputPath error:nil].fileSize;
    video[@"size"] = @(size);
    video[@"width"] = @(asset.pixelWidth);
    video[@"height"] = @(asset.pixelHeight);
   // video[@"favorite"] = @(asset.favorite);
    video[@"duration"] = @(asset.duration);
    //video[@"mediaType"] = @(asset.mediaType);
   // video[@"coverUri"] = [self handleCropImage:coverImage phAsset:asset quality:quality][@"uri"];
    return video;
}
/// 创建缓存目录
+ (BOOL)createCache {
    NSString * path = [NSString stringWithFormat:@"%@PicturePickerCaches", NSTemporaryDirectory()];;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if  (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        //先判断目录是否存在，不存在才创建
        BOOL res = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        return res;
    } else return NO;
}


- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end

