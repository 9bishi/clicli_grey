import 'dart:convert';
import 'dart:math' show max;

import 'package:clicli_grey/api/post.dart';
import 'package:clicli_grey/instance.dart';
import 'package:clicli_grey/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class VersionManager {
  static Future<PackageInfo> getAppVersion() async {
    return await PackageInfo.fromPlatform();
  }

  static int compare(String v1, String v2) {
    if (v1 == v2) return 0;

    List<String> v1Arr = v1.split('.');
    List<String> v2Arr = v2.split('.');
    int i = 0;
    int diff = 0;
    int v1l = v1Arr.length;
    int v2l = v2Arr.length;
    int maxLen = max(v1Arr.length, v2Arr.length);

    if (v1l < maxLen) v1Arr.addAll(List.generate(maxLen - v1l, (i) => '0'));
    if (v2l < maxLen) v2Arr.addAll(List.generate(maxLen - v2l, (i) => '0'));

    while (
        i < maxLen && (diff = int.parse(v1Arr[i]) - int.parse(v2Arr[i])) == 0) {
      ++i;
    }

    if (diff > 0) {
      return 1;
    } else if (diff < 0) {
      return -1;
    } else {
      return 0;
    }
  }

  static Future<int?> checkUpdate() async {
    final appInfo = jsonDecode((await checkAppUpdateApi()).data);
    final localAppInfo = (await getAppVersion());

    final int major = compare(
        appInfo['elements'][0]['versionName'].toString(), localAppInfo.version);

    if (major > 0 || major < 0) {
      return major;
    } else if (major == 0) {
      return 0;
    }

    return 0;
  }
}

Future<void> checkAppUpdate() async {
  int? status;

  try {
    status = await VersionManager.checkUpdate();
    if (status! > 0) {
      showDialog(
          barrierDismissible: false,
          context: Instances.currentContext,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text('提示'),
                content: const Text('有新版本可用ヾ(≧ ▽ ≦)ゝ'),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('更新'),
                    onPressed: () {
                      launchUrlString(
                          'https://cdn.jsdelivr.net/npm/@clicli/app@latest/web/app-release.apk');
                    },
                  ),
                ],
              ),
            );
          });
    } else {
      showSnackBar('已是最新版本');
    }
  } catch (e) {
    print(e);
    showErrorSnackBar('检测更新失败');
  }
}
