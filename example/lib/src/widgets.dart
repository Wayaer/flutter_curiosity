import 'package:curiosity/src/platform_support.dart';
import 'package:flutter/material.dart';

/// 页面分区标题。
class PageSection extends StatelessWidget {
  const PageSection({super.key, required this.title, this.description, required this.children});

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        if (description != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }
}

/// 单个功能演示卡片。
class DemoCard extends StatelessWidget {
  const DemoCard({super.key, required this.title, required this.description, required this.support, this.child});

  final String title;
  final String description;
  final Set<DemoPlatform> support;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DemoPlatform? current = DemoPlatform.current;
    final bool supported = current != null && support.contains(current);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              '支持平台：${PlatformSets.describe(support)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (supported && child != null) ...<Widget>[const SizedBox(height: 14), child!],
            if (!supported && current != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                '当前平台（${current.label}）不支持此功能。',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 提示条语气。
enum MessageTone { info, success, warning, error }

/// 卡片内的提示条。
class MessageBanner extends StatelessWidget {
  const MessageBanner({super.key, required this.tone, required this.message});

  final MessageTone tone;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (Color background, Color foreground) = switch (tone) {
      MessageTone.info => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      MessageTone.success => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      MessageTone.warning => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      MessageTone.error => (scheme.errorContainer, scheme.onErrorContainer),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
      child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: foreground)),
    );
  }
}

/// 一行键值信息。
class FactRow extends StatelessWidget {
  const FactRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 112,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

/// 显示一条 SnackBar 提示。
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
