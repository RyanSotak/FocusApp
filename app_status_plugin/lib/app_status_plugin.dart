
import 'app_status_plugin_platform_interface.dart';

class AppStatusPlugin {
  Future<String?> getPlatformVersion() {
    return AppStatusPluginPlatform.instance.getPlatformVersion();
  }
}
