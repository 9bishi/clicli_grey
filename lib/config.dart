import 'package:path_provider/path_provider.dart';

class Config {
  static const String jpushKey = 'a8e4d99ac7f968133d73ff19';

  static Future<String> downloadPath() async {
    return (await getExternalStorageDirectory())!.path;
  }

  // 是否开发环境
  static bool isDev = !const bool.fromEnvironment("dart.vm.product");
}
