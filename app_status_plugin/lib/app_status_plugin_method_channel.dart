import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_status_plugin_platform_interface.dart';

/// An implementation of [AppStatusPluginPlatform] that uses method channels.
class MethodChannelAppStatusPlugin extends AppStatusPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('app_status_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
