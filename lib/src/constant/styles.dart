import 'package:flutter/material.dart';

class BaseTextStyle extends TextStyle {
  const BaseTextStyle(
      {Color color,
      double fontSize,
      double height,
      FontWeight fontWeight,
      TextDecoration decoration})
      : super(
            decoration: decoration ?? TextDecoration.none,
            fontWeight: fontWeight ?? FontWeight.w500,
            fontSize: fontSize ?? 14,
            height: height,
            color: color);
}

/// start 合并到 end
TextStyle mergeTextStyle(TextStyle startStyle, TextStyle endStyle) {
  if (startStyle != null && endStyle != null) endStyle.merge(startStyle);
  return endStyle;
}
