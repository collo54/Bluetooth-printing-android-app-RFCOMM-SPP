
import 'trytwo_platform_interface.dart';

class Trytwo {
  Future<String?> getPlatformVersion() {
    return TrytwoPlatform.instance.getPlatformVersion();
  }
}
