import 'package:flutter/material.dart';

class Styles {
  static TextStyle textStyle(
          {Color color,
          double fontSize,
          double height,
          FontWeight fontWeight,
          TextDecoration decoration}) =>
      TextStyle(
          decoration: TextDecoration.none,
          fontWeight: fontWeight ?? FontWeight.w500,
          fontSize: fontSize ?? 14,
          height: height,
          color: color);

  //start 合并到 end
  static TextStyle mergeTextStyle(TextStyle startStyle, TextStyle endStyle) {
    if (startStyle != null && endStyle != null) endStyle.merge(startStyle);
    return endStyle;
  }
}
