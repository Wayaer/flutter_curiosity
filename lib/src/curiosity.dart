import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_curiosity/src/desktop.dart';
import 'package:flutter_curiosity/src/native.dart';

class Curiosity {
  factory Curiosity() {
    _singleton ??= Curiosity._();
    return _singleton!;
  }

  Curiosity._();

  static Curiosity? _singleton;

  GalleryTools get gallery => GalleryTools();

  NativeTools get native => NativeTools();

  CuriosityEvent get event => CuriosityEvent();

  DesktopTools get desktop => DesktopTools();
}
