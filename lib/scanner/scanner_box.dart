import 'package:flutter/material.dart';

class ScannerShadow extends StatelessWidget {
  const ScannerShadow({Key? key, this.child, this.size, this.clipSize})
      : super(key: key);
  final Widget? child;

  /// 整个阴影的颜色 [size] == null 使用父组件的宽高¬
  final Size? size;

  /// 内部裁剪区域大小
  final Size? clipSize;

  @override
  Widget build(BuildContext context) {
    Widget current = Align(alignment: Alignment.center, child: child);
    if (clipSize != null)
      current = CustomPaint(
          foregroundPainter:
              _ScannerShadowPainter(clipSize: clipSize!, color: Colors.black38),
          child: current);
    if (size != null) current = SizedBox.fromSize(size: size, child: current);
    return current;
  }
}

class _ScannerShadowPainter extends CustomPainter {
  const _ScannerShadowPainter({
    required this.clipSize,
    required this.color,
  });

  final Size clipSize;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = (size.width - clipSize.width) / 2;
    final double h = (size.height - clipSize.height) / 2;
    late final Paint paintValue = Paint()
      ..color = color
      ..strokeWidth = 10;
    final Path path = Path();
    path.addRect(Rect.fromLTWH(0, 0, w, size.height));
    path.addRect(Rect.fromLTWH(w, 0, clipSize.width, h));
    path.addRect(Rect.fromLTWH(size.width - w, 0, w, size.height));
    path.addRect(Rect.fromLTWH(w, size.height - h, clipSize.width, h));
    canvas.drawPath(path, paintValue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 扫码框动画
class ScannerBox extends StatefulWidget {
  const ScannerBox(
      {Key? key,
      this.child,
      this.borderColor,
      this.scannerColor,
      this.size,
      this.hornStrokeWidth,
      this.scannerStrokeWidth})
      : super(key: key);

  /// 扫码框内的组件
  final Widget? child;

  /// [size]==null 使用父组件的宽高
  final Size? size;

  /// 四角线宽度
  final double? hornStrokeWidth;

  /// 四边线宽度
  final double? scannerStrokeWidth;

  /// 四边线颜色
  final Color? borderColor;

  /// 中间滚动线颜色
  final Color? scannerColor;

  @override
  _ScannerBoxState createState() => _ScannerBoxState();
}

class _ScannerBoxState extends State<ScannerBox> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        Widget current = CustomPaint(
            painter: ScannerPainter(
                scannerStrokeWidth: widget.scannerStrokeWidth,
                hornStrokeWidth: widget.hornStrokeWidth,
                value: controller.value,
                borderColor: widget.borderColor,
                scannerColor: widget.scannerColor),
            child: widget.child,
            willChange: true);
        if (widget.size != null)
          current = SizedBox.fromSize(size: widget.size, child: current);
        return current;
      });
}

/// 扫码框+浅色背景
class ScannerPainter extends CustomPainter {
  ScannerPainter({
    double? hornStrokeWidth,
    double? scannerStrokeWidth,
    double? hornWidth,
    Color? scannerColor,
    Color? borderColor,
    required this.value,
  })  : scannerColor = scannerColor ?? Colors.white,
        borderColor = borderColor ?? Colors.white,
        hornStrokeWidth = hornStrokeWidth ?? 4,
        hornWidth = hornWidth ?? 15,
        scannerStrokeWidth = scannerStrokeWidth ?? 2;
  final double value;
  final Color borderColor;
  final Color scannerColor;

  /// 四角的线宽度
  final double hornStrokeWidth;

  /// 四角线长度
  final double hornWidth;

  /// 识别框中间的线
  final double scannerStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    late final Paint paintValue = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    paintValue.strokeWidth = scannerStrokeWidth;
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paintValue);
    paintValue.strokeWidth = hornStrokeWidth;
    final Path path = Path()
      ..moveTo(0, hornWidth)
      ..lineTo(0, 0)
      ..lineTo(hornWidth, 0)
      ..moveTo(size.width - hornWidth, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, hornWidth)
      ..moveTo(size.width, size.height - hornWidth)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - hornWidth, size.height)
      ..moveTo(hornWidth, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - hornWidth);
    canvas.drawPath(path, paintValue);
    final Rect scanRect =
        Rect.fromLTWH(10, value * (size.height - 20), size.width - 20, 0);
    final List<double> stop = <double>[0.0, 0.5, 1];
    paintValue.shader = LinearGradient(colors: <Color>[
      scannerColor.withOpacity(0.2),
      scannerColor,
      scannerColor.withOpacity(0.2),
    ], stops: stop)
        .createShader(scanRect);
    paintValue.strokeWidth = scannerStrokeWidth;
    canvas.drawRect(scanRect, paintValue);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
