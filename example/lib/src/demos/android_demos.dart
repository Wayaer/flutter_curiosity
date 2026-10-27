import 'package:curiosity/src/platform_support.dart';
import 'package:curiosity/src/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';

/// 演示 [NativeTools.getInstalledApps]。
class InstalledAppsDemo extends StatefulWidget {
  const InstalledAppsDemo({super.key});

  @override
  State<InstalledAppsDemo> createState() => _InstalledAppsDemoState();
}

class _InstalledAppsDemoState extends State<InstalledAppsDemo> {
  bool loading = false;
  bool loaded = false;
  List<AppPackageInfo> apps = const <AppPackageInfo>[];

  Future<void> loadApps() async {
    setState(() => loading = true);
    final List<AppPackageInfo> result = await Curiosity.native.getInstalledApps;
    if (!mounted) return;
    setState(() {
      apps = result;
      loading = false;
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '已安装应用',
      description: '读取设备上已安装应用的名称、包名和版本。Android 11+ 需要 QUERY_ALL_PACKAGES 权限。',
      support: PlatformSets.androidOnly,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FilledButton.icon(
            onPressed: loading ? null : loadApps,
            icon: Icon(loading ? Icons.hourglass_top_rounded : Icons.refresh_rounded),
            label: Text(loading ? '读取中...' : '读取已安装应用'),
          ),
          if (loaded) ...<Widget>[
            const SizedBox(height: 12),
            MessageBanner(tone: MessageTone.success, message: '共 ${apps.length} 个应用'),
            const SizedBox(height: 8),
            for (final AppPackageInfo app in apps.take(6))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(app.appName, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(app.packageName, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(app.version),
              ),
            if (apps.length > 6) Text('... 还有 ${apps.length - 6} 个'),
          ],
        ],
      ),
    );
  }
}

/// 演示 [NativeTools.getPackageInfo]。
class PackageInfoDemo extends StatefulWidget {
  const PackageInfoDemo({super.key});

  @override
  State<PackageInfoDemo> createState() => _PackageInfoDemoState();
}

class _PackageInfoDemoState extends State<PackageInfoDemo> {
  final TextEditingController controller = TextEditingController(text: 'com.tencent.mm');
  bool loading = false;
  bool loaded = false;
  AppPackageInfo? info;

  Future<void> lookup() async {
    setState(() => loading = true);
    final AppPackageInfo? result = await Curiosity.native.getPackageInfo(controller.text.trim());
    if (!mounted) return;
    setState(() {
      info = result;
      loading = false;
      loaded = true;
    });
  }

  String formatTime(int milliseconds) {
    if (milliseconds <= 0) return '-';
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String pad(int value) => value.toString().padLeft(2, '0');
    return '${time.year}-${pad(time.month)}-${pad(time.day)} ${pad(time.hour)}:${pad(time.minute)}:${pad(time.second)}';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPackageInfo? value = info;
    return DemoCard(
      title: '包信息',
      description: '按包名查询单个应用，默认查询微信。Android 11+ 需要在 <queries> 中声明该包名。',
      support: PlatformSets.androidOnly,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: '包名', hintText: 'com.tencent.mm'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : lookup,
            icon: Icon(loading ? Icons.hourglass_top_rounded : Icons.search_rounded),
            label: Text(loading ? '查询中...' : '查询包信息'),
          ),
          if (loaded) ...<Widget>[
            const SizedBox(height: 12),
            if (value == null)
              const MessageBanner(tone: MessageTone.warning, message: '未找到该应用，或未在 <queries> 中声明。')
            else ...<Widget>[
              FactRow(label: '应用名称', value: value.appName),
              FactRow(label: '包名', value: value.packageName),
              FactRow(label: '版本', value: value.version),
              FactRow(label: '构建号', value: value.buildNumber),
              FactRow(label: '系统应用', value: value.isSystemApp ? '是' : '否'),
              FactRow(label: '最后更新', value: formatTime(value.lastUpdateTime)),
              FactRow(label: '首次安装', value: formatTime(value.firstInstallTime)),
            ],
          ],
        ],
      ),
    );
  }
}

/// 演示 [NativeTools.installApk]。
class InstallApkDemo extends StatefulWidget {
  const InstallApkDemo({super.key});

  @override
  State<InstallApkDemo> createState() => _InstallApkDemoState();
}

class _InstallApkDemoState extends State<InstallApkDemo> {
  final TextEditingController controller = TextEditingController();
  bool loading = false;
  bool? result;

  Future<void> install() async {
    setState(() => loading = true);
    final bool started = await Curiosity.native.installApk(controller.text.trim());
    if (!mounted) return;
    setState(() {
      result = started;
      loading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '安装 APK',
      description: '调起 Android 系统安装器。需要 REQUEST_INSTALL_PACKAGES 权限。',
      support: PlatformSets.androidOnly,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'APK 路径', hintText: '/sdcard/Download/app.apk'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : install,
            icon: Icon(loading ? Icons.hourglass_top_rounded : Icons.download_rounded),
            label: Text(loading ? '正在调起安装器...' : '安装 APK'),
          ),
          if (result != null) ...<Widget>[
            const SizedBox(height: 12),
            MessageBanner(
              tone: result! ? MessageTone.success : MessageTone.error,
              message: result! ? '已打开系统安装器。' : '无法打开安装器，请检查路径和安装权限。',
            ),
          ],
        ],
      ),
    );
  }
}

/// 演示 [AndroidActivityResultState]。
class ActivityResultDemo extends StatefulWidget {
  const ActivityResultDemo({super.key});

  @override
  State<ActivityResultDemo> createState() => _ActivityResultDemoState();
}

class _ActivityResultDemoState extends AndroidActivityResultState<ActivityResultDemo> {
  @override
  void onAndroidActivityResult(AndroidActivityResult result) {
    super.onAndroidActivityResult(result);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AndroidActivityResult? result = activityResult;
    return DemoCard(
      title: 'Activity 结果',
      description: '继承 AndroidActivityResultState，自动监听并移除原生监听。',
      support: PlatformSets.androidOnly,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('正在监听 Activity 结果'),
          const SizedBox(height: 10),
          if (result == null)
            const MessageBanner(tone: MessageTone.info, message: '尚未收到 Activity 结果。')
          else ...<Widget>[
            FactRow(label: '请求码', value: '${result.requestCode}'),
            FactRow(label: '结果码', value: '${result.resultCode}'),
            FactRow(label: 'data', value: '${result.data}'),
            FactRow(label: 'extras', value: '${result.extras}'),
          ],
        ],
      ),
    );
  }
}
