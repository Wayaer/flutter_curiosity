class PicturePickerOptions {
  //支持ios && android
  int maxSelectNum; // 最大图片选择数量 int
  int minSelectNum; // 最小选择数量 int
  int selectionMode; //多选0 or 单选=1
  int cropW; //裁剪比例 如16:9 3:2 3:4 1:1 可自定义  宽
  int cropH; //裁剪比例 如16:9 3:2 3:4 1:1 可自定义  高
  int videoMaxSecond; //显示多少秒以内的视频or音频也可适用 int
  int pickerSelectType; //全部0、图片1、视频2、 音频3（3仅支持android）
  bool enableCrop; // 是否裁剪 true or false
  bool previewImage; // 是否可预览图片 true or false
  bool isCamera; // 是否显示拍照按钮 true or false
  bool isGif; // 是否显示gif图片 true or false
  int cropCompressQuality; // 裁剪压缩质量 默认90 int

  //android 以下为仅支持 android
  int imageSpanCount; // 每行显示个数 int
  int minimumCompressSize; // 小于100kb的图片不压缩
  int videoQuality; //视频录制质量 0 or 1 int
  int videoMinSecond; // 显示多少秒以内的视频or音频也可适用 int
  int recordVideoSecond; //视频秒数录制 默认60s int
  bool previewVideo; // 是否可预览视频 true or false
  bool isZoomAnim; // 图片列表点击 缩放效果 默认true
  bool compress; // 是否压缩 true or false
  bool hideBottomControls; // 是否显示uCrop工具栏，默认不显示 true or false
  bool freeStyleCropEnabled; // 裁剪框是否可拖拽 true or false
  bool showCropCircle; // 是否圆形裁剪 true or false
  bool showCropFrame; // 是否显示矩形 圆形裁剪时建议设为false    true or false
  bool showCropGrid; // 是否显示网格 圆形裁剪时建议设为false    true or false
  bool openClickSound; // 是否开启点击声音 true or false
  bool rotateEnabled; // 裁剪是否可旋转图片 true or false
  bool scaleEnabled; // 裁剪是否可放大缩小图片 true or false
  String setOutputCameraPath; // 自定义拍照保存路径,可不填

  //ios 以下为仅支持 ios
  int circleCropRadius; //圆形裁剪框半径大小  在单选模式下，照片列表页中，显示选择按钮,默认为false
  bool scaleAspectFillCrop; //是否图片等比缩放填充cropRect区域   在单选模式下，照片列表页中，显示选择按钮,默认为false
  bool originalPhoto; //是否显示原图按钮

  PicturePickerOptions(
      {this.maxSelectNum: 6,
      this.minSelectNum: 1,
      this.imageSpanCount: 4,
      this.selectionMode: 1,
      this.minimumCompressSize: 100,
      this.cropW: 4,
      this.cropH: 3,
      this.cropCompressQuality: 90,
      this.videoQuality: 0,
      this.videoMaxSecond: 60,
      this.videoMinSecond: 5,
      this.recordVideoSecond: 60,
      this.previewImage: false,
      this.previewVideo: false,
      this.isZoomAnim: true,
      this.isCamera: false,
      this.enableCrop: false,
      this.compress: false,
      this.hideBottomControls: false,
      this.freeStyleCropEnabled: false,
      this.showCropCircle: false,
      this.showCropFrame: false,
      this.showCropGrid: false,
      this.openClickSound: false,
      this.isGif: false,
      this.scaleAspectFillCrop: false,
      this.setOutputCameraPath: "",
      this.rotateEnabled: false,
      this.originalPhoto: false,
      this.scaleEnabled: false,
      this.pickerSelectType: 0});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['maxSelectNum'] = this.maxSelectNum ?? 6;
    data['minSelectNum'] = this.minSelectNum;
    data['imageSpanCount'] = this.imageSpanCount;
    data['selectionMode'] = this.selectionMode;
    data['minimumCompressSize'] = this.minimumCompressSize;
    data['cropW'] = this.cropW;
    data['cropH'] = this.cropH;
    data['cropCompressQuality'] = this.cropCompressQuality;
    data['videoQuality'] = this.videoQuality;
    data['videoMaxSecond'] = this.videoMaxSecond;
    data['videoMinSecond'] = this.videoMinSecond;
    data['recordVideoSecond'] = this.recordVideoSecond;
    data['previewImage'] = this.previewImage;
    data['previewVideo'] = this.previewVideo;
    data['isZoomAnim'] = this.isZoomAnim;
    data['enableCrop'] = this.enableCrop;
    data['compress'] = this.compress;
    data['isCamera'] = this.isCamera;
    data['hideBottomControls'] = this.hideBottomControls;
    data['freeStyleCropEnabled'] = this.freeStyleCropEnabled;
    data['showCropCircle'] = this.showCropCircle;
    data['showCropFrame'] = this.showCropFrame;
    data['showCropGrid'] = this.showCropGrid;
    data['openClickSound'] = this.openClickSound;
    data['isGif'] = this.isGif;
    data['rotateEnabled'] = this.rotateEnabled;
    data['scaleEnabled'] = this.scaleEnabled;
    data['pickerSelectType'] = this.pickerSelectType;
    data['setOutputCameraPath'] = this.setOutputCameraPath;
    data['scaleAspectFillCrop'] = this.scaleAspectFillCrop;
    data['originalPhoto'] = this.originalPhoto;

    return data;
  }
}
