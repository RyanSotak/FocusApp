import 'package:flutter_test/flutter_test.dart';
import 'package:app_status_plugin/app_status_plugin.dart';
import 'package:app_status_plugin/app_status_plugin_platform_interface.dart';
import 'package:app_status_plugin/app_status_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppStatusPluginPlatform
    with MockPlatformInterfaceMixin
    implements AppStatusPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AppStatusPluginPlatform initialPlatform = AppStatusPluginPlatform.instance;

  test('$MethodChannelAppStatusPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAppStatusPlugin>());
  });

  test('getPlatformVersion', () async {
    AppStatusPlugin appStatusPlugin = AppStatusPlugin();
    MockAppStatusPluginPlatform fakePlatform = MockAppStatusPluginPlatform();
    AppStatusPluginPlatform.instance = fakePlatform;

    expect(await appStatusPlugin.getPlatformVersion(), '42');
  });
}
