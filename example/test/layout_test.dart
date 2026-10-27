import 'package:curiosity/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<Size> sizes = <Size>[Size(390, 844), Size(720, 560), Size(1120, 760)];
  for (final Size size in sizes) {
    testWidgets('布局无溢出 ${size.width}x${size.height}', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const CuriosityExampleApp());
      await tester.pumpAndSettle();
      expect(find.text('系统能力'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('macOS 下 Scrollbar 有可用的 ScrollPosition', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.binding.setSurfaceSize(const Size(1120, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const CuriosityExampleApp());
      await tester.pumpAndSettle();
      expect(find.text('当前平台：macOS'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
