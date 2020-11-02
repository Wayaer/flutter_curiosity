import 'package:flutter/material.dart';

class ScannerBox extends StatefulWidget {
  const ScannerBox(
      {Key key,
      this.child,
      Color borderColor,
      Color scannerColor,
      this.size,
      this.boxSize,
      this.hornStrokeWidth,
      this.scannerStrokeWidth})
      : borderColor = borderColor ?? Colors.white,
        scannerColor = scannerColor ?? Colors.white,
        super(key: key);
  final Widget child;
  final Size size;
  final Size boxSize;
  final double hornStrokeWidth;
  final double scannerStrokeWidth;
  final Color borderColor;
  final Color scannerColor;

  @override
  _ScannerBoxState createState() => _ScannerBoxState();
}

class _ScannerBoxState extends State<ScannerBox> with TickerProviderStateMixin {
  AnimationController controller;

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
      builder: (BuildContext context, Widget child) => CustomPaint(
          foregroundPainter: ScannerPainter(
              scannerStrokeWidth: widget.scannerStrokeWidth,
              hornStrokeWidth: widget.hornStrokeWidth,
              value: controller.value,
              size: widget.size,
              boxSize: widget.boxSize,
              borderColor: widget.borderColor,
              scannerColor: widget.scannerColor),
          child: widget.child,
          willChange: true));
}

class ScannerPainter extends CustomPainter {
  ScannerPainter({
    double hornStrokeWidth,
    double scannerStrokeWidth,
    Color scannerColor,
    this.value,
    this.borderColor,
    this.size,
    this.boxSize,
  })  : hornStrokeWidth = hornStrokeWidth ?? 3,
        scannerColor = scannerColor ?? Colors.white,
        scannerStrokeWidth = scannerStrokeWidth ?? 0.5;
  final double value;
  final Color borderColor;
  final Color scannerColor;
  final Size size;
  final Size boxSize;

  ///四角的线宽度
  final double hornStrokeWidth;

  ///识别框中间的线
  final double scannerStrokeWidth;
  Paint paintValue;

  @override
  void paint(Canvas canvas, Size size) {
    final Size initSize = this.size ?? size;
    final Size initBoxSize =
        boxSize ?? Size(initSize.width * 0.7, initSize.height * 0.3);
    if (paintValue == null) initPaint();
    final double left = (initSize.width - initBoxSize.width) / 2;
    final double top = (initSize.height - initBoxSize.height) / 2;
    final double boxWidth = initBoxSize.width;
    final double boxHeight = initBoxSize.height;
    final double bottom = top + boxHeight;
    final double right = left + boxWidth;
    paintValue.color = borderColor;
    final Rect rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);
    canvas.drawRect(rect, paintValue);
    paintValue.strokeWidth = hornStrokeWidth;
    final Path path1 = Path()
      ..moveTo(left, top + 10)
      ..lineTo(left, top)
      ..lineTo(left + 10, top);
    canvas.drawPath(path1, paintValue);
    final Path path2 = Path()
      ..moveTo(left, bottom - 10)
      ..lineTo(left, bottom)
      ..lineTo(left + 10, bottom);
    canvas.drawPath(path2, paintValue);
    final Path path3 = Path()
      ..moveTo(right, bottom - 10)
      ..lineTo(right, bottom)
      ..lineTo(right - 10, bottom);
    canvas.drawPath(path3, paintValue);
    final Path path4 = Path()
      ..moveTo(right, top + 10)
      ..lineTo(right, top)
      ..lineTo(right - 10, top);
    canvas.drawPath(path4, paintValue);
    final Rect scanRect = Rect.fromLTWH(
        left + 10, top + 10 + (value * (boxHeight - 20)), boxWidth - 20, 0);
    final List<double> stop = <double>[0.0, 0.5, 1];
    paintValue.shader = LinearGradient(colors: <Color>[
      scannerColor.withOpacity(0.5),
      scannerColor,
      scannerColor.withOpacity(0.5),
    ], stops: stop)
        .createShader(scanRect);
    paintValue.strokeWidth = scannerStrokeWidth;
    canvas.drawRect(scanRect, paintValue);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void initPaint() {
    paintValue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel;
  }
}
