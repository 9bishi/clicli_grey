import 'package:path_provider/path_provider.dart';

class Config {
  static const String jpushKey = 'c4cc23b352d2510157ea7d88';

  static Future<String> downloadPath() async {
    return (await getExternalStorageDirectory())!.path;
  }

  // 是否开发环境
  static bool isDev = !const bool.fromEnvironment("dart.vm.product");
}
