import 'package:curiosity/src/platform_support.dart';
import 'package:curiosity/src/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

/// 演示 [NativeTools.gpsStatus]。
class GpsDemo extends StatefulWidget {
  const GpsDemo({super.key});

  @override
  State<GpsDemo> createState() => _GpsDemoState();
}

class _GpsDemoState extends State<GpsDemo> {
  bool loading = false;
  bool? status;

  Future<void> checkStatus() async {
    setState(() => loading = true);
    final bool enabled = await Curiosity.native.gpsStatus;
    if (!mounted) return;
    setState(() {
      loading = false;
      status = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: 'GPS 状态',
      description: '查询定位服务是否开启。Web 端查询浏览器的定位权限状态。',
      support: PlatformSets.gps,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FilledButton.icon(
            onPressed: loading ? null : checkStatus,
            icon: Icon(loading ? Icons.hourglass_top_rounded : Icons.my_location_rounded),
            label: Text(loading ? '查询中...' : '查询 GPS 状态'),
          ),
          if (status != null) ...<Widget>[
            const SizedBox(height: 12),
            MessageBanner(
              tone: status! ? MessageTone.success : MessageTone.warning,
              message: status! ? '定位服务已开启。' : '定位服务未开启，或浏览器未授予定位权限。',
            ),
          ],
        ],
      ),
    );
  }
}

/// 演示键盘监听、[NativeKeyboardStatus] 及平台参数。
class KeyboardDemo extends StatefulWidget {
  const KeyboardDemo({super.key});

  @override
  State<KeyboardDemo> createState() => _KeyboardDemoState();
}

class _KeyboardDemoState extends NativeKeyboardStatusState<KeyboardDemo> {
  final TextEditingController controller = TextEditingController();
  bool listenerEnabled = true;

  @override
  void onKeyboardListener(NativeKeyboardStatus params) {
    super.onKeyboardListener(params);
    if (mounted) setState(() {});
  }

  Future<void> toggleListener() async {
    if (listenerEnabled) {
      await removeKeyboardListener();
      if (!mounted) return;
      setState(() => listenerEnabled = false);
      showMessage(context, '已移除键盘监听');
      return;
    }
    final bool added = await addKeyboardListener();
    if (!mounted) return;
    setState(() => listenerEnabled = added);
    showMessage(context, added ? '已添加键盘监听' : '当前平台不支持键盘监听');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NativeKeyboardStatus? status = keyboardParams;
    return DemoCard(
      title: '键盘状态',
      description: '继承 NativeKeyboardStatusState 自动管理监听。聚焦输入框可触发键盘事件。',
      support: PlatformSets.keyboard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: '聚焦以打开键盘', hintText: '在此输入'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: toggleListener,
                icon: Icon(listenerEnabled ? Icons.pause_rounded : Icons.play_arrow_rounded),
                label: Text(listenerEnabled ? '移除监听' : '添加监听'),
              ),
              Text(listenerEnabled ? '监听中' : '已暂停'),
            ],
          ),
          const SizedBox(height: 14),
          _KeyboardFacts(status: listenerEnabled ? status : null),
          const SizedBox(height: 10),
          MessageBanner(tone: MessageTone.info, message: status == null ? '尚未收到键盘事件。' : '数值由系统以逻辑像素返回。'),
        ],
      ),
    );
  }
}

class _KeyboardFacts extends StatelessWidget {
  const _KeyboardFacts({required this.status});

  final NativeKeyboardStatus? status;

  @override
  Widget build(BuildContext context) {
    final NativeKeyboardStatus? value = status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FactRow(label: '可见性', value: value == null ? '-' : (value.visibility ? '是' : '否')),
        FactRow(label: '键盘高度', value: '${value?.keyboardHeight ?? '-'}'),
        if (Curiosity.isAndroid) ...<Widget>[
          FactRow(label: '屏幕密度', value: '${value?.android?.density ?? '-'}'),
          FactRow(label: '导航栏高度', value: '${value?.android?.navigationBarHeight ?? '-'}'),
        ],
        if (Curiosity.isIOS) ...<Widget>[
          FactRow(label: '键盘宽度', value: '${value?.ios?.width ?? '-'}'),
          FactRow(label: '原始高度', value: '${value?.ios?.height ?? '-'}'),
        ],
        if (Curiosity.isHarmonyOS) ...<Widget>[
          FactRow(label: '屏幕密度', value: '${value?.harmonyOS?.density ?? '-'}'),
          FactRow(label: '显示高度', value: '${value?.harmonyOS?.displayHeight ?? '-'}'),
        ],
        if (Curiosity.isWeb) ...<Widget>[
          FactRow(label: '视口宽度', value: '${value?.web?.width ?? '-'}'),
          FactRow(label: '视口高度', value: '${value?.web?.height ?? '-'}'),
        ],
      ],
    );
  }
}

/// 演示 [NativeTools.exitApp]。
class ExitDemo extends StatefulWidget {
  const ExitDemo({super.key});

  @override
  State<ExitDemo> createState() => _ExitDemoState();
}

class _ExitDemoState extends State<ExitDemo> {
  bool? exited;

  Future<void> requestExit() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('确定退出应用？'),
        content: Text(Curiosity.isWeb ? '浏览器会尝试关闭当前窗口，通常只允许关闭由脚本打开的窗口。' : '系统将关闭当前应用进程。'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('退出')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final bool? result = await Curiosity.native.exitApp();
    if (!mounted) return;
    setState(() => exited = result);
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '退出应用',
      description: '请求系统关闭应用。Web 端仅能关闭由脚本打开的窗口。',
      support: PlatformSets.all,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FilledButton.icon(onPressed: requestExit, icon: const Icon(Icons.logout_rounded), label: const Text('退出应用')),
          if (exited == false) ...<Widget>[
            const SizedBox(height: 12),
            const MessageBanner(tone: MessageTone.warning, message: '系统拒绝关闭应用，Web 端仅支持关闭由脚本打开的窗口。'),
          ],
        ],
      ),
    );
  }
}
