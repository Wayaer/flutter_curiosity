part of '../flutter_curiosity.dart';

class AndroidActivityResult {
  AndroidActivityResult.fromMap(Map<dynamic, dynamic> json) {
    requestCode = json['requestCode'] as int;
    resultCode = json['resultCode'] as int;
    data = json['data'] as dynamic;
    extras = json['extras'] as dynamic;
  }

  late int requestCode;
  late int resultCode;
  dynamic data;
  dynamic extras;
}

mixin AndroidActivityResultMixin {
  AndroidActivityResult? _activityResult;

  AndroidActivityResult? get activityResult => _activityResult;

  /// 添加监听
  /// 注意：需要在 initState 中调用
  void addAndroidActivityResultListener() {
    NativeTools().activityResult.add(onAndroidActivityResult);
  }

  void onAndroidActivityResult(AndroidActivityResult activityResult) {
    _activityResult = activityResult;
  }

  /// 监听回调
  /// 注意：需要在 dispose 中调用
  void removeAndroidActivityResultListener() {
    NativeTools().activityResult.remove(onAndroidActivityResult);
  }
}

abstract class AndroidActivityResultState<T extends StatefulWidget>
    extends State<T> with AndroidActivityResultMixin {
  @override
  void initState() {
    super.initState();
    addAndroidActivityResultListener();
  }

  @override
  void dispose() {
    super.dispose();
    removeAndroidActivityResultListener();
  }
}
