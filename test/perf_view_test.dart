import 'package:flutter_test/flutter_test.dart';
import 'package:perf_view/perf_view_method_channel.dart';
import 'package:perf_view/perf_view_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPerfViewPlatform
    with MockPlatformInterfaceMixin
    implements PerfViewPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
  @override
  Future<List<Object?>?> getNetworkInfo() => Future.value(null);
  @override
  Future<List<Object?>?> getMemoryInfo() => Future.value(null);
}

void main() {
  final PerfViewPlatform initialPlatform = PerfViewPlatform.instance;

  test('$MethodChannelPerfView is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPerfView>());
  });

  test('getPlatformVersion', () async {
    // PerfView perfViewPlugin = PerfView();
    // MockPerfViewPlatform fakePlatform = MockPerfViewPlatform();
    // PerfViewPlatform.instance = fakePlatform;

    // expect(await perfViewPlugin.getPlatformVersion(), '42');
  });
}
