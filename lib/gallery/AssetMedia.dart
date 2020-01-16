import 'dart:convert' show json;

import 'package:flutter_curiosity/utils/LogUtils.dart';

dynamic convertValueByType(value, Type type, {String stack: ""}) {
  if (value == null) {
    log("$stack : value is null");
    if (type == String) {
      return "";
    } else if (type == int) {
      return 0;
    } else if (type == double) {
      return 0.0;
    } else if (type == bool) {
      return false;
    }
    return null;
  }

  if (value.runtimeType == type) {
    return value;
  }
  var valueS = value.toString();
  log("$stack : ${value.runtimeType} is not $type type");
  if (type == String) {
    return valueS;
  } else if (type == int) {
    return int.tryParse(valueS);
  } else if (type == double) {
    return double.tryParse(valueS);
  } else if (type == bool) {
    valueS = valueS.toLowerCase();
    var intValue = int.tryParse(valueS);
    if (intValue != null) {
      return intValue == 1;
    }
    return valueS == "true";
  }
}

class AssetMedia {
  String compressPath;
  String cropPath;
  int duration;
  int height;
  String path;
  int size;
  int width;

  AssetMedia({
    this.compressPath,
    this.cropPath,
    this.duration,
    this.height,
    this.path,
    this.size,
    this.width,
  });

  factory AssetMedia.fromJson(jsonRes) =>
      jsonRes == null
          ? null
          : AssetMedia(
        compressPath: convertValueByType(jsonRes['compressPath'], String,
            stack: "AssetMedia-compressPath"),
        cropPath: convertValueByType(jsonRes['cutPath'], String,
            stack: "AssetMedia-cutPath"),
        duration: convertValueByType(jsonRes['duration'], int,
            stack: "AssetMedia-duration"),
        height: convertValueByType(jsonRes['height'], int,
            stack: "AssetMedia-height"),
        path: convertValueByType(jsonRes['path'], String,
            stack: "AssetMedia-path"),
        size: convertValueByType(jsonRes['size'], int,
            stack: "AssetMedia-size"),
        width: convertValueByType(jsonRes['width'], int,
            stack: "AssetMedia-width"),
      );

  Map<String, dynamic> toJson() =>
      {
        'compressPath': compressPath,
        'cutPath': cropPath,
        'duration': duration,
        'height': height,
        'path': path,
        'size': size,
        'width': width,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
