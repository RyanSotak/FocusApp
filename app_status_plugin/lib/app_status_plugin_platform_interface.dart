import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_status_plugin_method_channel.dart';

abstract class AppStatusPluginPlatform extends PlatformInterface {
  /// Constructs a AppStatusPluginPlatform.
  AppStatusPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppStatusPluginPlatform _instance = MethodChannelAppStatusPlugin();

  /// The default instance of [AppStatusPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppStatusPlugin].
  static AppStatusPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppStatusPluginPlatform] when
  /// they register themselves.
  static set instance(AppStatusPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
