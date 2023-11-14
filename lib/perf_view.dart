
import 'perf_view_platform_interface.dart';

class PerfView {
  Future<String?> getPlatformVersion() {
    return PerfViewPlatform.instance.getPlatformVersion();
  }
}
