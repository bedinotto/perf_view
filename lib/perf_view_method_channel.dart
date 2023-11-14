import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'perf_view_platform_interface.dart';

/// An implementation of [PerfViewPlatform] that uses method channels.
class MethodChannelPerfView extends PerfViewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('perf_view');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
