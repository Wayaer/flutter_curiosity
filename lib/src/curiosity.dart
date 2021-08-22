import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/desktop.dart';
import 'package:flutter_curiosity/src/native.dart';

class Curiosity {
  factory Curiosity() => _getInstance();

  Curiosity._internal();

  static Curiosity get instance => _getInstance();

  static Curiosity? _instance;

  static Curiosity _getInstance() {
    _instance ??= Curiosity._internal();
    return _instance!;
  }

  GalleryTools get gallery => GalleryTools.instance;

  NativeTools get native => NativeTools.instance;

  CuriosityEvent get event => CuriosityEvent.instance;

  DesktopTools get desktop => DesktopTools.instance;
}
