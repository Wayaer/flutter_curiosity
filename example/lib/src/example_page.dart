import 'package:curiosity/src/demos/android_demos.dart';
import 'package:curiosity/src/demos/gallery_demos.dart';
import 'package:curiosity/src/demos/system_demos.dart';
import 'package:curiosity/src/platform_support.dart';
import 'package:curiosity/src/widgets.dart';
import 'package:flutter/material.dart';

/// 单页示例：按平台能力展示全部插件功能。
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DemoPlatform? current = DemoPlatform.current;
    return Scaffold(
      appBar: AppBar(title: const Text('Curiosity')),
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            primary: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: <Widget>[
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '当前平台：${current?.label ?? "未知"}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '所有功能按平台能力启用，不支持的演示会显示说明。',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const PageSection(
                title: '系统能力',
                description: 'GPS、键盘状态和退出应用。',
                children: <Widget>[GpsDemo(), KeyboardDemo(), ExitDemo()],
              ),
              const PageSection(
                title: 'Android 专属',
                description: '仅在 Android 上可用。',
                children: <Widget>[InstalledAppsDemo(), PackageInfoDemo(), InstallApkDemo(), ActivityResultDemo()],
              ),
              const PageSection(
                title: '图片保存',
                description: '移动端保存到相册，macOS、Windows 和 Linux 保存到图片文件夹，Web 触发下载。',
                children: <Widget>[SaveBytesImageDemo(), SaveFilePathDemo()],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
