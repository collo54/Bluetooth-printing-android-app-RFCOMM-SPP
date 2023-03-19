import 'package:flutter_test/flutter_test.dart';
import 'package:trytwo/trytwo.dart';
import 'package:trytwo/trytwo_platform_interface.dart';
import 'package:trytwo/trytwo_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTrytwoPlatform
    with MockPlatformInterfaceMixin
    implements TrytwoPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TrytwoPlatform initialPlatform = TrytwoPlatform.instance;

  test('$MethodChannelTrytwo is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTrytwo>());
  });

  test('getPlatformVersion', () async {
    Trytwo trytwoPlugin = Trytwo();
    MockTrytwoPlatform fakePlatform = MockTrytwoPlatform();
    TrytwoPlatform.instance = fakePlatform;

    expect(await trytwoPlugin.getPlatformVersion(), '42');
  });
}
