import 'dart:io';

bool get isInternalMacOS => Platform.isMacOS;

bool get isInternalWindows => Platform.isWindows;

bool get isInternalLinux => Platform.isLinux;

bool get isInternalAndroid => Platform.isAndroid;

bool get isInternalIOS => Platform.isIOS;

bool get isInternalFuchsia => Platform.isFuchsia;

bool get isInternalDesktop =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

bool get isInternalMobile => Platform.isIOS || Platform.isAndroid;
