import 'dart:async';

import 'package:clicli_grey/utils/toast_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../instance.dart';

class Response {
  Response(this.data);

  String data;
}

class HttpClient extends http.BaseClient {
  final http.Client _inner;

  HttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['clicli-user-agent'] = '$Instances.appVersion';
    request.headers['Content-Type'] = 'application/json';
    return _inner.send(request);
  }
}

class NetUtils {
  static final httpClient = HttpClient(http.Client());

  static sink() {
    httpClient.close();
  }

  static Future<Response> _send(String method, String url, {data}) async {
    debugPrint('http $method $url $data');
    Response response = Response('');
    try {
      if (method == "GET") {
        response = Response((await httpClient.get(Uri.parse(url))).body);
      } else {
        response =
            Response((await httpClient.post(Uri.parse(url), body: jsonEncode(data))).body);
      }
    } catch (e) {
      debugPrint('http error $e');
      showErrorSnackBar('网络似乎出了一点问题');
    }

    return response;
  }

  static Future get(String url) {
    return _send('GET', url);
  }

  static Future post(String url, data) {
    return _send('POST', url, data: data);
  }
}
