part of '../flutter_curiosity.dart';

/// The result of an Android activity.
class AndroidActivityResult {
  /// Creates an [AndroidActivityResult] from a map received from Android.
  AndroidActivityResult.fromMap(Map<dynamic, dynamic> map)
    : requestCode = map['requestCode'] as int? ?? 0,
      resultCode = map['resultCode'] as int? ?? 0,
      data = map['data'],
      extras = map['extras'];

  /// The request code of the activity.
  final int requestCode;

  /// The result code of the activity.
  final int resultCode;

  /// The data URI returned by the activity.
  final dynamic data;

  /// The extras returned by the activity.
  final dynamic extras;

  @override
  String toString() => 'AndroidActivityResult(requestCode: $requestCode, resultCode: $resultCode, data: $data)';
}

/// Mixin that listens to [AndroidActivityResult] events.
mixin AndroidActivityResultMixin {
  AndroidActivityResult? _activityResult;

  /// The latest activity result.
  AndroidActivityResult? get activityResult => _activityResult;

  /// Adds an activity result listener.
  ///
  /// Call it from [State.initState].
  void addAndroidActivityResultListener() {
    NativeTools.instance.activityResult.add(onAndroidActivityResult);
  }

  /// Called when an activity result is received. Override to handle it.
  void onAndroidActivityResult(AndroidActivityResult result) {
    _activityResult = result;
  }

  /// Removes the activity result listener.
  ///
  /// Call it from [State.dispose].
  void removeAndroidActivityResultListener() {
    NativeTools.instance.activityResult.remove(onAndroidActivityResult);
  }
}

/// A [State] that listens to [AndroidActivityResult] events.
abstract class AndroidActivityResultState<T extends StatefulWidget> extends State<T> with AndroidActivityResultMixin {
  @override
  void initState() {
    super.initState();
    addAndroidActivityResultListener();
  }

  @override
  void dispose() {
    removeAndroidActivityResultListener();
    super.dispose();
  }
}
