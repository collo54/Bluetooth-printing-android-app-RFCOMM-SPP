import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'trytwo_platform_interface.dart';

/// An implementation of [TrytwoPlatform] that uses method channels.
class MethodChannelTrytwo extends TrytwoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('trytwo');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
