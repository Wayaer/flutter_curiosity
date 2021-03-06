#import "CuriosityPlugin.h"
#import "ScannerTools.h"
#import "NativeTools.h"
#import "GalleryTools.h"
#import "ScannerView.h"
#import <Photos/Photos.h>

@implementation CuriosityPlugin{
    UIViewController *viewController;
    NSObject<FlutterPluginRegistrar> *registrar;
    FlutterMethodCall *call;
    FlutterMethodChannel *curiosityChannel;
    FlutterResult result;
    ScannerView *scannerView;
    BOOL keyboardStatus;
}
NSString * const curiosity=@"Curiosity";
NSString * const scannerEvent=@"Curiosity/event/scanner";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:curiosity
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    CuriosityPlugin* plugin = [[CuriosityPlugin alloc] initWithCuriosity:registrar :viewController :channel];
    [registrar addMethodCallDelegate:plugin channel:channel];
    
}
- (instancetype)initWithCuriosity:(NSObject<FlutterPluginRegistrar>*)_registrar
                                 :(UIViewController *)_viewController
                                 :(FlutterMethodChannel*)_channel{
    self = [super init];
    viewController = _viewController;
    registrar = _registrar;
    curiosityChannel = _channel;
    keyboardStatus = NO;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didShow) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(didShow) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(didHide) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}
- (void)handleMethodCall:(FlutterMethodCall*)_call result:(FlutterResult)_result {
    call = _call;
    result = _result;
    if ([@"openSystemGallery" isEqualToString:call.method]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        [GalleryTools openSystemGallery:viewController :picker :result];
    }else if ([@"openSystemCamera" isEqualToString:call.method]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        [GalleryTools openSystemCamera:viewController :picker :result];
    }else if ([@"saveImageToGallery" isEqualToString:call.method]) {
        [self saveImageToGallery];
    }else if ([@"saveFileToGallery" isEqualToString:call.method]) {
        [self saveFileToGallery];
    }else if ([@"scanImagePath" isEqualToString:call.method]) {
        [ScannerTools scanImagePath:call result:result];
    }else if ([@"scanImageUrl" isEqualToString:call.method]) {
        [ScannerTools scanImageUrl:call result:result];
    }else if ([@"scanImageMemory" isEqualToString:call.method]) {
        [ScannerTools scanImageMemory:call result:result];
    }else if ([@"availableCameras" isEqualToString:call.method]) {
        [ScannerTools availableCameras:call result:result];
    }else if([@"initializeCameras" isEqualToString:call.method]){
        NSString *cameraId = call.arguments[@"cameraId"];
        NSString *resolutionPreset = call.arguments[@"resolutionPreset"];
        NSError * error;
        
        //相机消息通道
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:scannerEvent binaryMessenger:[registrar messenger]];
        
        ScannerView *view = [[ScannerView alloc] initWitchCamera:cameraId :eventChannel :resolutionPreset :&error];
        if(error){
            result(getFlutterError(error));
            return;
        }else{
            if(scannerView)[scannerView close];
            int64_t scannerViewId = [registrar.textures registerTexture:view];
            scannerView = view;
            [eventChannel setStreamHandler:view];
            view.onFrameAvailable = ^{
                [self->registrar.textures textureFrameAvailable:scannerViewId];
            };
            result(@{
                @"cameraState":@"onOpened",
                @"textureId":@(scannerViewId),
                @"previewWidth":@(view.previewSize.width),
                @"previewHeight":@(view.previewSize.height)
                   });
            [view start];
        }
    }else if([@"disposeCameras" isEqualToString:call.method]){
        NSUInteger textureId = [call.arguments numberValue].unsignedIntegerValue;
        if(scannerView)[scannerView close];
        if(textureId) [registrar.textures unregisterTexture:textureId];
        result([Tools resultInfo:@"dispose"]);
    }else if ([call.method isEqualToString:@"setFlashMode"]){
        if(scannerView)[scannerView setFlashMode:[call.arguments boolValue]];
        result([Tools resultInfo:@"setFlashMode"]);
    }else if ([@"getGPSStatus" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[NativeTools getGPSStatus]]);
    }else if ([@"openSystemSetting" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[NativeTools openSystemSetting]]);
    }else if ([@"getAppInfo" isEqualToString:call.method]) {
        result([NativeTools getAppInfo]);
    }else if ([@"getDeviceInfo" isEqualToString:call.method]) {
        result([NativeTools getDeviceInfo]);
    }else if ([@"openSystemShare" isEqualToString:call.method]) {
        [NativeTools openSystemShare:call result:result];
    }else if ([@"exitApp" isEqualToString:call.method]) {
        exit(0);
    }else{
        result(FlutterMethodNotImplemented);
    }
}

- (void)didShow{
    if (!keyboardStatus) {
        keyboardStatus = YES;
        [curiosityChannel invokeMethod:@"keyboardStatus" arguments:[NSNumber numberWithBool:keyboardStatus]];
    }
}

- (void)willShow{
    if (!keyboardStatus) {
        keyboardStatus = YES;
        [curiosityChannel invokeMethod:@"keyboardStatus" arguments:[NSNumber numberWithBool:keyboardStatus]];
    }
}

- (void)didHide{
    if (keyboardStatus) {
        keyboardStatus = NO;
        [curiosityChannel invokeMethod:@"keyboardStatus" arguments:[NSNumber numberWithBool:keyboardStatus]];
    }
}




#pragma mark - UIImagePickerControllerDelegate

//选择拍照和图库回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        //图库选择图片
        if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            NSString * imageUrl = [NSString stringWithFormat:@"%@",info[@"UIImagePickerControllerImageURL"]];
            self->result(imageUrl);
        }
        //拍照回调
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            __block NSString* localId;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest * assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                localId = [[assetChangeRequest placeholderForCreatedAsset] localIdentifier];
            } completionHandler:^(BOOL success, NSError *error) {
                PHFetchResult* assetResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
                PHAsset * asset = [assetResult firstObject];
                [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                    self->result(contentEditingInput.fullSizeImageURL.absoluteString);
                }];
            }];
        }
    }];
}


//进入拍摄页面点击取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        self->result(@"cancel");
    }];
}

- (void)saveImageToGallery{
    NSDictionary * arguments = call.arguments;
    FlutterStandardTypedData *imageBytes = [arguments objectForKey:@"imageBytes"];
    int quality = [[arguments objectForKey:@"quality"] intValue];
    //    NSString *name = [[arguments objectForKey:@"name"] stringValue];
    UIImage *image = [UIImage imageWithData:imageBytes.data];
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:UIImageJPEGRepresentation(image, quality/100)], self,@selector(saveImage:didFinishSavingWithError:contextInfo:), nil);
}

- (void)saveFileToGallery{
    NSString * path = call.arguments;
    if([Tools isImageFile:path]){
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:path],self,@selector(saveImage:didFinishSavingWithError:contextInfo:),nil);
    }else if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)){
        UISaveVideoAtPathToSavedPhotosAlbum(path,self,@selector(saveVideo:didFinishSavingWithError:contextInfo:),nil);
    }else{
        result([Tools resultInfo:@"File types that cannot be saved"]);
    }
    
}
#pragma mark - 保存图片或视频完成的回调
- (void)saveImage:(UIImage *)image didFinishSavingWithError:(NSError *)error
      contextInfo:(void *)contextInfo {
    result(error?[Tools resultFail]:[Tools resultSuccess]);
}
- (void)saveVideo:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
      contextInfo:(void *)contextInfo {
    result(error?[Tools resultFail]:[Tools resultSuccess]);
}
static FlutterError *getFlutterError(NSError *error) {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"%d", (int)error.code]
                               message:error.localizedDescription
                               details:error.domain];
}
@end
