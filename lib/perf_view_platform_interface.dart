import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'perf_view_method_channel.dart';

abstract class PerfViewPlatform extends PlatformInterface {
  /// Constructs a PerfViewPlatform.
  PerfViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static PerfViewPlatform _instance = MethodChannelPerfView();

  /// The default instance of [PerfViewPlatform] to use.
  ///
  /// Defaults to [MethodChannelPerfView].
  static PerfViewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PerfViewPlatform] when
  /// they register themselves.
  static set instance(PerfViewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<Object?>?> getNetworkInfo() {
    throw UnimplementedError('getNetworkInfo() has not been implemented.');
  }

  Future<List<Object?>?> getMemoryInfo() {
    throw UnimplementedError('getMemoryInfo() has not been implemented.');
  }
}
