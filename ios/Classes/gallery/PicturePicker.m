#import "PicturePicker.h"
#import "TZImageManager.h"
#import "TZImageCropManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface PicturePicker ()

//@property (nonatomic, strong) UIImagePickerController *picker;

@end
@implementation PicturePicker

+ (void)openPicker:(NSDictionary *)arguments viewController:(UIViewController*)viewController  result:(FlutterResult)result{
    
    //    NSLog(@"LogInfo%@",arguments);
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
        picker.maxImagesCount=1;
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
    
    TZImageManager *manager= [TZImageManager manager];
    __weak TZImagePickerController *weakPicker = picker;
    [picker setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        [weakPicker showProgressHUD];
        if (selectionMode == 1 && enableCrop) {
            result([self resultImage:(UIImage *)photos asset:assets[0] quality:cropCompressQuality]);
        } else {
            NSMutableArray *selectedPhotos = [NSMutableArray array];
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                if (asset.mediaType == PHAssetMediaTypeVideo) {
                    [manager getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetHighestQuality success:^(NSString *outputPath) {
                        [selectedPhotos addObject:[self resultVideo:outputPath asset:asset coverImage:photos[idx] quality:cropCompressQuality]];
                        if ([selectedPhotos count] == [assets count]) {
                            result(selectedPhotos);
                        }
                        if (idx + 1 == [assets count] && [selectedPhotos count] != [assets count]) {
                            result(@"fail");
                        }
                    } failure:^(NSString *errorMessage, NSError *error) {
                        
                    }];
                } else {
                    BOOL isGIF = [manager getAssetType:asset] == TZAssetModelMediaTypePhotoGif;
                    if (isGIF || isSelectOriginalPhoto) {
                        [manager requestImageDataForAsset:asset completion:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                            [selectedPhotos addObject:[self resultOriginalPhotoData:imageData phAsset:asset isGIF:isGIF quality:cropCompressQuality]];
                            if ([selectedPhotos count] == [assets count]) {
                                result(selectedPhotos);
                            }
                            if (idx + 1 == [assets count] && [selectedPhotos count] != [assets count]) {
                                result(@"fail");
                            }
                        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                            
                        }];
                    } else {
                        [selectedPhotos addObject:[self resultImage:photos[idx] asset:asset quality:cropCompressQuality]];
                        if ([selectedPhotos count] == [assets count]) {
                            result(selectedPhotos);
                        }
                    }
                }
            }];
        }
        [weakPicker hideProgressHUD];
    }];
    [picker setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        [weakPicker showProgressHUD];
        [manager getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetHighestQuality success:^(NSString *outputPath) {
            result([self resultVideo:outputPath asset:asset coverImage:coverImage quality:cropCompressQuality]);
            
            [weakPicker dismissViewControllerAnimated:YES completion:nil];
            [weakPicker hideProgressHUD];
        } failure:^(NSString *errorMessage, NSError *error) {
            //            NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
            result(@"视频导出失败");
            [weakPicker dismissViewControllerAnimated:YES completion:nil];
            [weakPicker hideProgressHUD];
        }];
    }];
    [picker setImagePickerControllerDidCancelHandle:^{
        //        NSLog(@"LogInfo%@",@"cancel");
        result(@"cancel");
    }];
    [picker setDidFinishPickingGifImageHandle:^(UIImage *animatedImage, id sourceAssets) {
        //        NSLog(@"LogInfo%@",sourceAssets);
    }];
    
    
    [viewController presentViewController:picker animated:YES completion:nil];
}


+ (void)openCamera:(NSDictionary *)arguments  viewController:(UIViewController*)viewController  result:(FlutterResult)result{
    //    NSLog(@"LogInfo%@",arguments);
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PicturePicker openCamera:  arguments viewController:viewController result:result];
                });
            }
        }];
        // 拍照之前还需要检查相册权限
    } else if ([PHPhotoLibrary authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if ([PHPhotoLibrary authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [PicturePicker openCamera:  arguments viewController:viewController result:result];
        }];
    } else {
        UIImagePickerController *picker=   [[UIImagePickerController alloc] init];
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = sourceType;
            [viewController presentViewController:picker   animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
    
}


+ (void)deleteCacheDirFile{
    
    
    
}
/// 处理原图数据
+ (NSDictionary *)resultOriginalPhotoData:(NSData *)data phAsset:(PHAsset *)asset isGIF:(BOOL)isGIF quality:(CGFloat)quality {
    [self createCache];
    NSMutableDictionary *photo  = [NSMutableDictionary dictionary];
    NSString *filename = [NSString stringWithFormat:@"%@%@", [[NSUUID UUID] UUIDString], [asset valueForKey:@"filename"]];
    NSString *fileExtension    = [filename pathExtension];
    UIImage *image = nil;
    NSData *writeData = nil;
    NSMutableString *filePath = [NSMutableString string];
    
    BOOL isPNG = [fileExtension hasSuffix:@"PNG"] || [fileExtension hasSuffix:@"png"];
    
    if (isGIF) {
        image = [UIImage sd_tz_animatedGIFWithData:data];
        writeData = data;
    } else {
        image = [UIImage imageWithData: data];
        writeData = isPNG ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, quality/100);
    }
    
    if (isPNG || isGIF) {
        [filePath appendString:[NSString stringWithFormat:@"%@PicturePickerCaches/%@", NSTemporaryDirectory(), filename]];
    } else {
        [filePath appendString:[NSString stringWithFormat:@"%@PicturePickerCaches/%@.jpg", NSTemporaryDirectory(), [filename stringByDeletingPathExtension]]];
    }
    
    [writeData writeToFile:filePath atomically:YES];
    
    photo[@"fileName"]  = filename;
    photo[@"path"]      = filePath;
    photo[@"width"]     = @(image.size.width);
    photo[@"height"]    = @(image.size.height);
    NSInteger size      = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize;
    photo[@"size"]      = @(size);
    photo[@"mediaType"] = @(asset.mediaType);
    
    return photo;
}

// 图片数据
+ (NSDictionary *)resultImage:(UIImage *)image asset:(PHAsset *)asset quality:(CGFloat)quality {
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
    photo[@"fileName"]  = filename;
    photo[@"path"]      = filePath;
    photo[@"width"]     = @(image.size.width);
    photo[@"height"]    = @(image.size.height);
    NSInteger size = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize;
    photo[@"size"] = @(size);
    photo[@"mediaType"] = @(asset.mediaType);
    return photo;
}
/// 视频数据
+ (NSDictionary *)resultVideo:(NSString *)outputPath asset:(PHAsset *)asset coverImage:(UIImage *)coverImage quality:(CGFloat)quality {
    NSMutableDictionary *video = [NSMutableDictionary dictionary];
//    NSString *filename = [NSString stringWithFormat:@"%@%@", [[NSUUID UUID] UUIDString], [asset valueForKey:@"filename"]];
//    
//    video[@"fileName"] = filename;
    video[@"path"] = outputPath;
    NSInteger size = [[NSFileManager defaultManager] attributesOfItemAtPath:outputPath error:nil].fileSize;
    video[@"size"] = @(size);
    video[@"width"] = @(asset.pixelWidth);
    video[@"height"] = @(asset.pixelHeight);
    // video[@"favorite"] = @(asset.favorite);
    video[@"duration"] = @(asset.duration);
    video[@"mediaType"] = @(asset.mediaType);
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

