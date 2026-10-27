import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Captures the widget wrapped by [boundaryKey] as a PNG.
Future<Uint8List?> captureBoundaryPng(GlobalKey boundaryKey, BuildContext context) async {
  final RenderObject? renderObject = boundaryKey.currentContext?.findRenderObject();
  if (renderObject is! RenderRepaintBoundary) return null;
  final ui.Image image = await renderObject.toImage(pixelRatio: MediaQuery.devicePixelRatioOf(context));
  try {
    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
