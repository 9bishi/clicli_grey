import 'dart:convert';

import 'package:crypto/crypto.dart';

String getSuo(String? content) {
  final m = RegExp('suo(.+?)\\)')
          .firstMatch(content ?? 'xxxxxxxxxxxxxxxxx')
          ?.group(1) ??
      '';
  String src;
  if (m.isNotEmpty && m.substring(2).isNotEmpty) {
    src = m.substring(2);
    if (m.substring(2)[0] == ' ') {
      src = src.substring(1);
    }
    return Uri.decodeComponent(src);
  }
  return 'https://ae01.alicdn.com/kf/U4862d28d28b545fcbd56d54bd3849639h.jpg';
}

getAvatar({avatar = ''}) {
  if (RegExp('^[0-9]+\$').hasMatch(avatar)) {
    return 'https://q1.qlogo.cn/g?b=qq&nk=$avatar&s=640';
  } else {
    final hash = generateMd5(avatar);
    return 'https://sdn.geekzu.org/avatar/$hash?s=100&d=retro';
  }
}

String generateMd5(String data) {
  return md5.convert(utf8.encode(data)).toString();
}
