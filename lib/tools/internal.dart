import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_curiosity/constant/constant.dart';
import 'package:flutter_curiosity/platform/platform.dart';

final MediaQueryData mediaQueryData = MediaQueryData.fromWindow(window);

/// size → Size 设备尺寸信息，如屏幕的大小，单位 pixels
Size get getWindowSize => mediaQueryData.size;

/// devicePixelRatio → double 单位逻辑像素的设备像素数量，即设备像素比。
/// 这个数字可能不是2的幂，实际上它甚至也可能不是整数。例如，Nexus 6的设备像素比为3.5。
double get getDevicePixelRatio => mediaQueryData.devicePixelRatio;
const int _limitLength = 800;

void log<T>(T msg) {
  final String message = msg.toString();
  if (isDebug) {
    if (message.length < _limitLength) {
      print(msg);
    } else {
      _segmentationLog(message);
    }
  }
}

bool get supportPlatformDesktop {
  if (!isWeb && isDesktop) return true;
  log('Curiosity is not support Platform');
  return false;
}

bool get supportPlatform {
  if (!isWeb && (isMobile || isMacOS)) return true;
  log('Curiosity is not support Platform');
  return false;
}

bool get supportPlatformMobile {
  if (isMobile) return true;
  log('Curiosity is not support Platform');
  return false;
}

void _segmentationLog(String msg) {
  final StringBuffer outStr = StringBuffer();
  for (int index = 0; index < msg.length; index++) {
    outStr.write(msg[index]);
    if (index % _limitLength == 0 && index != 0) {
      print(outStr);
      outStr.clear();
      final int lastIndex = index + 1;
      if (msg.length - lastIndex < _limitLength) {
        final String remainderStr = msg.substring(lastIndex, msg.length);
        print(remainderStr);
        break;
      }
    }
  }
}

String macOSSettingPathToString(MacOSSettingPath path) {
  switch (path) {
    case MacOSSettingPath.accessibilityMain:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess';
    case MacOSSettingPath.accessibilityDisplay:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Display';
    case MacOSSettingPath.accessibilityZoom:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Zoom';
    case MacOSSettingPath.accessibilityVoiceOver:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_VoiceOver';
    case MacOSSettingPath.accessibilityDescriptions:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess?Media_Descriptions';
    case MacOSSettingPath.accessibilityCaptions:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess?Captioning';
    case MacOSSettingPath.accessibilityAudio:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess?Hearing';
    case MacOSSettingPath.accessibilityKeyboard:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess?Keyboard';
    case MacOSSettingPath.accessibilityMouseTrackpad:
      return 'x-apple.systempreferences:com.apple.preference.universalaccess?Mouse';
    case MacOSSettingPath.securityMain:
      return 'x-apple.systempreferences:com.apple.preference.security';
    case MacOSSettingPath.securityGeneral:
      return 'x-apple.systempreferences:com.apple.preference.security?General';
    case MacOSSettingPath.securityFileVault:
      return 'x-apple.systempreferences:com.apple.preference.security?FDE';
    case MacOSSettingPath.securityFirewall:
      return 'x-apple.systempreferences:com.apple.preference.security?Firewall';
    case MacOSSettingPath.securityAdvanced:
      return 'x-apple.systempreferences:com.apple.preference.security?Advanced';
    case MacOSSettingPath.securityPrivacy:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy';
    case MacOSSettingPath.securityPrivacyAccessibility:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility';
    case MacOSSettingPath.securityPrivacyAssistive:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy_Assistive';
    case MacOSSettingPath.securityPrivacyAllFiles:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles';
    case MacOSSettingPath.securityPrivacyLocationServices:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices';
    case MacOSSettingPath.securityPrivacyContacts:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts';
    case MacOSSettingPath.securityPrivacyDiagnosticsUsage:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy_Diagnostics';
    case MacOSSettingPath.securityPrivacyCalendars:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars';
    case MacOSSettingPath.securityPrivacyReminders:
      return 'x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders';
    case MacOSSettingPath.speechDictation:
      return 'x-apple.systempreferences:com.apple.preference.speech?Dictation';
    case MacOSSettingPath.speechTextToSpeech:
      return 'x-apple.systempreferences:com.apple.preference.speech?TTS';
    case MacOSSettingPath.sharingMain:
      return 'x-apple.systempreferences:com.apple.preferences.sharing';
    case MacOSSettingPath.sharingScreenSharing:
      return 'x-apple.systempreferences:com.apple.preferences.sharing?Services_ScreenSharing';
    case MacOSSettingPath.sharingFileSharing:
      return 'x-apple.systempreferences:com.apple.preferences.sharing?Services_PersonalFileSharing';
    case MacOSSettingPath.sharingPrinterSharing:
      return 'x-apple.systempreferences:com.apple.preferences.sharing?Services_PrinterSharing';
    case MacOSSettingPath.sharingRemoteLogin:
      return 'x-apple.systempreferences:com.apple.preferences.sharing?Services_RemoteLogin';
    case MacOSSettingPath.sharingRemoteManagement:
      return 'x-apple.systempreferences:com.apple.preferences.sharing?Services_ARDService';
    case MacOSSettingPath.sharingRemoteAppleEvents:
      return 'x-apple.systempreferences:com.apple.preferences.sharing?Services_RemoteAppleEvent';
    case MacOSSettingPath.sharingInternetSharing:
      return 'x-apple.systempreferences:com.apple.preferences.sharing?Internet';
    case MacOSSettingPath.sharingBluetoothSharing:
      return 'x-apple.systempreferences:com.apple.preferences.sharing?Services_BluetoothSharing';
  }
}
