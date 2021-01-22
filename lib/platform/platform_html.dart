import 'dart:html' as html;

html.Navigator _navigator = html.window.navigator;

bool get isInternalMacOS =>
    _navigator.appVersion.contains('Mac OS') && !isInternalIOS;

bool get isInternalWindows => _navigator.appVersion.contains('Win');

bool get isInternalLinux =>
    (_navigator.appVersion.contains('Linux') ||
        _navigator.appVersion.contains('x11')) &&
    !isInternalAndroid;

/// @check https://developer.chrome.com/multidevice/user-agent
bool get isInternalAndroid => _navigator.appVersion.contains('Android ');

/// maxTouchPoints is needed to separate iPad iOS13 vs new MacOS
bool get isInternalIOS =>
    _hasMatch(_navigator.platform, r'/iPad|iPhone|iPod/') ||
    (_navigator.platform == 'MacIntel' && _navigator.maxTouchPoints > 1);

bool get isInternalFuchsia => false;

bool _hasMatch(String value, String pattern) {
  if (value == null) return false;
  return RegExp(pattern).hasMatch(value);
}
