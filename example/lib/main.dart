import 'package:curiosity/src/example_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CuriosityExampleApp());
}

/// flutter_curiosity 示例应用。
class CuriosityExampleApp extends StatelessWidget {
  const CuriosityExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curiosity',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const ExamplePage(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF5B5BD6), brightness: brightness);
  }
}
