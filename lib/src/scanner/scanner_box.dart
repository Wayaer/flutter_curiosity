import 'package:flutter/material.dart';import 'package:flutter_curiosity/src/tools/internal.dart';class ScannerBox extends StatefulWidget {  final Widget child;  final Color borderColor;  final Color scannerColor;  final Size size;  final double hornStrokeWidth;  final double scannerStrokeWidth;  ScannerBox(      {Key key,      this.child,      Color borderColor,      Color scannerColor,      this.size,      this.hornStrokeWidth,      this.scannerStrokeWidth})      : this.borderColor = borderColor ?? Colors.white,        this.scannerColor = scannerColor ?? Colors.white,        super(key: key);  @override  ScannerBoxState createState() => ScannerBoxState();}class ScannerBoxState extends State<ScannerBox> with TickerProviderStateMixin {  AnimationController controller;  @override  void initState() {    super.initState();    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));    controller.repeat(reverse: true);  }  @override  void dispose() {    controller.dispose();    super.dispose();  }  @override  Widget build(BuildContext context) {    return AnimatedBuilder(        animation: controller,        builder: (BuildContext context, Widget child) => CustomPaint(              foregroundPainter: ScannerPainter(                  scannerStrokeWidth: widget.scannerStrokeWidth,                  hornStrokeWidth: widget.hornStrokeWidth,                  value: controller.value,                  size: widget.size,                  borderColor: widget.borderColor,                  scannerColor: widget.scannerColor),              child: widget.child,              willChange: true,            ));  }}class ScannerPainter extends CustomPainter {  final double value;  final Color borderColor;  final Color scannerColor;  final Size size;  ///四角的线宽度  final double hornStrokeWidth;  ///识别框中间的线  final double scannerStrokeWidth;  ScannerPainter({    double hornStrokeWidth,    double scannerStrokeWidth,    Color scannerColor,    this.value,    this.borderColor,    this.size,  })  : this.hornStrokeWidth = hornStrokeWidth ?? 3,        this.scannerColor = scannerColor ?? Colors.white,        this.scannerStrokeWidth = scannerStrokeWidth ?? 0.5;  Paint paintValue;  @override  void paint(Canvas canvas, Size s) {    Size initSize = size ?? Size(s.width * 0.7, s.height * 0.3);    if (paintValue == null) initPaint();    double width = InternalTools.getSize().width;    double height = InternalTools.getSize().height;    double left = (width - initSize.width) / 2;    double top = (height - initSize.height) / 2;    double boxWidth = initSize.width;    double boxHeight = initSize.height;    double bottom = top + boxHeight;    double right = left + boxWidth;    paintValue.color = borderColor;    final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);    canvas.drawRect(rect, paintValue);    paintValue.strokeWidth = hornStrokeWidth;    Path path1 = Path()      ..moveTo(left, top + 10)      ..lineTo(left, top)      ..lineTo(left + 10, top);    canvas.drawPath(path1, paintValue);    Path path2 = Path()      ..moveTo(left, bottom - 10)      ..lineTo(left, bottom)      ..lineTo(left + 10, bottom);    canvas.drawPath(path2, paintValue);    Path path3 = Path()      ..moveTo(right, bottom - 10)      ..lineTo(right, bottom)      ..lineTo(right - 10, bottom);    canvas.drawPath(path3, paintValue);    Path path4 = Path()      ..moveTo(right, top + 10)      ..lineTo(right, top)      ..lineTo(right - 10, top);    canvas.drawPath(path4, paintValue);    final scanRect = Rect.fromLTWH(left + 10, top + 10 + (value * (boxHeight - 20)), boxWidth - 20, 0);    paintValue.shader = LinearGradient(colors: <Color>[      scannerColor.withOpacity(0.5),      scannerColor,      scannerColor.withOpacity(0.5),    ], stops: [      0.0,      0.5,      1,    ]).createShader(scanRect);    paintValue.strokeWidth = scannerStrokeWidth;    canvas.drawRect(scanRect, paintValue);  }  @override  bool shouldRepaint(CustomPainter oldDelegate) => true;  void initPaint() {    paintValue = Paint()      ..style = PaintingStyle.stroke      ..strokeWidth = 0.5      ..isAntiAlias = true      ..strokeCap = StrokeCap.round      ..strokeJoin = StrokeJoin.bevel;  }}