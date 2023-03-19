import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'trytwo_method_channel.dart';

abstract class TrytwoPlatform extends PlatformInterface {
  /// Constructs a TrytwoPlatform.
  TrytwoPlatform() : super(token: _token);

  static final Object _token = Object();

  static TrytwoPlatform _instance = MethodChannelTrytwo();

  /// The default instance of [TrytwoPlatform] to use.
  ///
  /// Defaults to [MethodChannelTrytwo].
  static TrytwoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TrytwoPlatform] when
  /// they register themselves.
  static set instance(TrytwoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
