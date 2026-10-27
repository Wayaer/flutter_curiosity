import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web implementation based on browser APIs.
class WebPlatform {
  static JSFunction? _onVisualViewportResize;
  static web.VisualViewport? _visualViewport;
  static void Function(Map<String, dynamic> status)? _keyboardListener;

  /// Returns whether the geolocation permission is granted.
  ///
  /// Browsers do not expose the GPS hardware state, so this is a best-effort
  /// check of the permission state.
  static Future<bool> getGpsStatus() async {
    try {
      final JSObject descriptor = <String, String>{'name': 'geolocation'}.jsify()! as JSObject;
      final web.PermissionStatus status = await web.window.navigator.permissions.query(descriptor).toDart;
      return status.state == 'granted';
    } catch (_) {
      return false;
    }
  }

  /// Requests the browser to close the current window.
  ///
  /// Browsers only allow this for windows opened by script.
  static Future<bool> exitApp() async {
    web.window.close();
    return web.window.closed;
  }

  /// Starts reporting keyboard status using the visual viewport.
  static bool addKeyboardListener(void Function(Map<String, dynamic> status) listener) {
    final web.VisualViewport? visualViewport = web.window.visualViewport;
    if (visualViewport == null) return false;
    removeKeyboardListener();
    _visualViewport = visualViewport;
    _keyboardListener = listener;
    _onVisualViewportResize = ((web.Event event) => _emitKeyboardStatus()).toJS;
    visualViewport.addEventListener('resize', _onVisualViewportResize);
    _emitKeyboardStatus();
    return true;
  }

  /// Stops reporting keyboard status.
  static void removeKeyboardListener() {
    final web.VisualViewport? visualViewport = _visualViewport;
    final JSFunction? onResize = _onVisualViewportResize;
    if (visualViewport != null && onResize != null) {
      visualViewport.removeEventListener('resize', onResize);
    }
    _visualViewport = null;
    _onVisualViewportResize = null;
    _keyboardListener = null;
  }

  /// Downloads [bytes] through the browser.
  static bool saveBytesImage(Uint8List bytes, String name, String extension) {
    try {
      final String mimeType = extension == 'jpeg' ? 'image/jpeg' : 'image/$extension';
      final List<JSAny> parts = <JSAny>[bytes.toJS];
      final web.Blob blob = web.Blob(parts.toJS, web.BlobPropertyBag(type: mimeType));
      final String url = web.URL.createObjectURL(blob);
      final web.HTMLAnchorElement anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = '$name.$extension';
      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
      Future<void>.delayed(const Duration(seconds: 1), () {
        web.URL.revokeObjectURL(url);
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Emits the current keyboard status to the registered listener.
  static void _emitKeyboardStatus() {
    final void Function(Map<String, dynamic> status)? listener = _keyboardListener;
    final web.VisualViewport? visualViewport = _visualViewport;
    if (listener == null || visualViewport == null) return;
    final num hiddenHeight = web.window.innerHeight - visualViewport.height;
    final num keyboardHeight = hiddenHeight < 0 ? 0 : hiddenHeight;
    final bool visible = keyboardHeight > 50;
    listener(<String, dynamic>{
      'visibility': visible,
      'height': visible ? keyboardHeight : 0,
      'width': visualViewport.width,
    });
  }
}
