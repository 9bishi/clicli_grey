import 'package:clicli_dark/config.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Instances {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get navigatorState =>
      Instances.navigatorKey.currentState!;

  static BuildContext get currentContext => navigatorState.overlay!.context;

  static ThemeData get currentTheme => Theme.of(navigatorState.context);

  static Color get currentThemeColor => currentTheme.primaryColor;

  static late SharedPreferences sp;

  static EventBus eventBus = EventBus();

  static late JPush jp;

  static String appVersion = '';

  static init() async {
    if (!Config.isDev && !kIsWeb) {
      jp = JPush();
      jp.setup(appKey: Config.jpushKey, channel: 'developer-default');
    }
    sp = await SharedPreferences.getInstance();
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      final String v = packageInfo.version;
      final String buildNumber = packageInfo.buildNumber;
      appVersion = '$v.$buildNumber';
    });
  }

  static clear() {}
}
