import 'dart:typed_data';

import 'package:curiosity/src/platform_support.dart';
import 'package:curiosity/src/temp_file_stub.dart' if (dart.library.io) 'package:curiosity/src/temp_file_io.dart';
import 'package:curiosity/src/widgets.dart';
import 'package:curiosity/src/widgets/capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

/// 演示 [ImageGalleryTools.saveBytesImage]。
class SaveBytesImageDemo extends StatefulWidget {
  const SaveBytesImageDemo({super.key});

  @override
  State<SaveBytesImageDemo> createState() => _SaveBytesImageDemoState();
}

class _SaveBytesImageDemoState extends State<SaveBytesImageDemo> {
  final GlobalKey boundaryKey = GlobalKey();
  final TextEditingController nameController = TextEditingController();
  ImageGalleryExtension extension = ImageGalleryExtension.png;
  int quality = 100;
  bool loading = false;
  bool? saved;

  bool get canConvert => Curiosity.isAndroid || Curiosity.isIOS || Curiosity.isHarmonyOS || Curiosity.isMacOS;

  Future<void> save() async {
    setState(() {
      loading = true;
      saved = null;
    });
    final Uint8List? bytes = await captureBoundaryPng(boundaryKey, context);
    if (!mounted) return;
    if (bytes == null) {
      setState(() => loading = false);
      showMessage(context, '截取预览图失败');
      return;
    }
    final String name = nameController.text.trim();
    final bool result = await ImageGalleryTools.saveBytesImage(
      bytes,
      quality: quality,
      name: name.isEmpty ? null : name,
      extension: canConvert ? extension : ImageGalleryExtension.png,
    );
    if (!mounted) return;
    setState(() {
      loading = false;
      saved = result;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '保存图片字节',
      description: '截取下方预览图，按所选格式保存。移动端保存到相册，macOS、Windows 和 Linux 保存到图片文件夹，Web 触发下载。',
      support: PlatformSets.galleryBytes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RepaintBoundary(
            key: boundaryKey,
            child: const _ImagePreview(title: '示例图片'),
          ),
          const SizedBox(height: 14),
          if (canConvert) ...<Widget>[
            Text('图片格式', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            SegmentedButton<ImageGalleryExtension>(
              segments: const <ButtonSegment<ImageGalleryExtension>>[
                ButtonSegment(value: ImageGalleryExtension.jpeg, label: Text('JPEG')),
                ButtonSegment(value: ImageGalleryExtension.png, label: Text('PNG')),
              ],
              selected: <ImageGalleryExtension>{extension},
              onSelectionChanged: (Set<ImageGalleryExtension> selection) => setState(() => extension = selection.first),
            ),
            const SizedBox(height: 12),
            Text('图片质量：$quality', style: Theme.of(context).textTheme.labelMedium),
            Slider(
              value: quality.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: '$quality',
              onChanged: (double value) => setState(() => quality = value.round()),
            ),
          ] else
            Text(
              '当前平台固定保存为 PNG。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: '文件名（可选）', hintText: '我的图片'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : save,
            icon: Icon(loading ? Icons.hourglass_top_rounded : Icons.save_alt_rounded),
            label: Text(loading ? '保存中...' : _saveLabel),
          ),
          if (saved != null) ...<Widget>[
            const SizedBox(height: 12),
            MessageBanner(
              tone: saved! ? MessageTone.success : MessageTone.error,
              message: saved! ? _successMessage : _failureMessage,
            ),
          ],
        ],
      ),
    );
  }

  String get _saveLabel {
    if (Curiosity.isWeb) return '下载图片';
    if (Curiosity.isMacOS || Curiosity.isWindows || Curiosity.isLinux) return '保存到图片文件夹';
    return '保存到相册';
  }

  String get _successMessage {
    if (Curiosity.isWeb) return '已开始下载。';
    if (Curiosity.isMacOS || Curiosity.isWindows || Curiosity.isLinux) return '已保存到图片文件夹。';
    return '已保存到系统相册。';
  }

  String get _failureMessage {
    if (Curiosity.isMacOS) return '保存失败，请确认应用有“图片”文件夹的读写权限。';
    return '保存失败。';
  }
}

/// 演示 [ImageGalleryTools.saveFilePath]。
class SaveFilePathDemo extends StatefulWidget {
  const SaveFilePathDemo({super.key});

  @override
  State<SaveFilePathDemo> createState() => _SaveFilePathDemoState();
}

class _SaveFilePathDemoState extends State<SaveFilePathDemo> {
  final GlobalKey boundaryKey = GlobalKey();
  final TextEditingController nameController = TextEditingController();
  bool loading = false;
  bool? saved;

  Future<void> save() async {
    setState(() {
      loading = true;
      saved = null;
    });
    final Uint8List? bytes = await captureBoundaryPng(boundaryKey, context);
    if (!mounted) return;
    if (bytes == null) {
      setState(() => loading = false);
      showMessage(context, '截取预览图失败');
      return;
    }
    final String? tempPath = await writeTempPng(bytes);
    if (!mounted) return;
    if (tempPath == null) {
      setState(() => loading = false);
      showMessage(context, '当前平台没有可用的文件系统');
      return;
    }
    final String name = nameController.text.trim();
    final bool result = await ImageGalleryTools.saveFilePath(tempPath, name: name.isEmpty ? null : name);
    if (!mounted) return;
    setState(() {
      loading = false;
      saved = result;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '保存文件',
      description: '先把预览图写入临时文件，再通过 saveFilePath 保存。移动端保存到相册，macOS、Windows 和 Linux 保存到图片文件夹。',
      support: PlatformSets.galleryFile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RepaintBoundary(
            key: boundaryKey,
            child: const _ImagePreview(title: '临时图片文件'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: '保存文件名（可选）', hintText: '我的图片'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : save,
            icon: Icon(loading ? Icons.hourglass_top_rounded : Icons.insert_drive_file_outlined),
            label: Text(loading ? '保存中...' : _saveLabel),
          ),
          if (saved != null) ...<Widget>[
            const SizedBox(height: 12),
            MessageBanner(
              tone: saved! ? MessageTone.success : MessageTone.error,
              message: saved! ? _successMessage : _failureMessage,
            ),
          ],
        ],
      ),
    );
  }

  String get _saveLabel {
    if (Curiosity.isMacOS || Curiosity.isWindows || Curiosity.isLinux) return '保存到图片文件夹';
    return '保存到相册';
  }

  String get _successMessage {
    if (Curiosity.isMacOS || Curiosity.isWindows || Curiosity.isLinux) return '已复制到图片文件夹。';
    return '已保存到系统相册。';
  }

  String get _failureMessage {
    if (Curiosity.isMacOS) return '保存失败，请确认应用有“图片”文件夹的读写权限。';
    return '保存失败。';
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0EA5E9), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.image_rounded, color: Colors.white, size: 36),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
