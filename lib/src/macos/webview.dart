import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_curiosity/src/internal.dart';

enum PresentationStyle {
  modal,
  sheet,
}
enum WebResourceErrorType {
  unknown,
  webContentProcessTerminated,
  webViewInvalidated,
  javaScriptExceptionOccurred,
  javaScriptResultTypeIsUnsupported,
}

class MacOSWebView {
  MacOSWebView({
    this.onOpen,
    this.onClose,
    this.onPageStarted,
    this.onPageFinished,
    this.onWebResourceError,
  }) : _channel = const MethodChannel(curiosity);

  final MethodChannel _channel;

  final void Function()? onOpen;
  final void Function()? onClose;
  final void Function(String? url)? onPageStarted;
  final void Function(String? url)? onPageFinished;
  final void Function(WebResourceError error)? onWebResourceError;

  Future<bool?> open({
    required String url,
    bool javascriptEnabled = true,
    PresentationStyle presentationStyle = PresentationStyle.sheet,
    Size? size,
    // Offset origin,
    String? userAgent,
    String modalTitle = '',
    String sheetCloseButtonTitle = 'Close',
  }) async {
    assert(url.trim().isNotEmpty);
    _channel.setMethodCallHandler(_onMethodCall);
    return await _channel.invokeMethod<bool?>('openWebView', {
      'url': url,
      'javascriptEnabled': javascriptEnabled,
      'presentationStyle': presentationStyle.index,
      'customSize': size != null,
      'width': size?.width,
      'height': size?.height,
      'userAgent': userAgent,
      'modalTitle': modalTitle,
      'sheetCloseButtonTitle': sheetCloseButtonTitle,
      // 'customOrigin': origin != null,
      // 'x': origin?.dx,
      // 'y': origin?.dy,
    });
  }

  /// Closes WebView
  Future<bool?> close() async {
    _channel.setMethodCallHandler(null);
    return await _channel.invokeMethod<bool?>('closeWebView');
  }

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onOpen':
        onOpen?.call();
        return;
      case 'onClose':
        onClose?.call();
        return;
      case 'onPageStarted':
        onPageStarted?.call(call.arguments['url']);
        return;
      case 'onPageFinished':
        onPageFinished?.call(call.arguments['url']);
        return;
      case 'onWebResourceError':
        onWebResourceError?.call(WebResourceError(
            errorCode: call.arguments['errorCode'],
            description: call.arguments['description'],
            domain: call.arguments['domain'],
            errorType: call.arguments['errorType'] == null
                ? null
                : WebResourceErrorType.values.firstWhere(
                    (type) {
                      return type.toString() ==
                          '$WebResourceErrorType.${call.arguments['errorType']}';
                    },
                  )));
        return;
    }
  }
}

class WebResourceError {
  WebResourceError({
    required this.errorCode,
    required this.description,
    this.domain,
    this.errorType,
  });

  final int errorCode;
  final String description;
  final String? domain;
  final WebResourceErrorType? errorType;
}
