import 'dart:convert';
import 'dart:ui';

import 'package:clicli_grey/api/post.dart';
import 'package:clicli_grey/instance.dart';
import 'package:clicli_grey/service/events.dart';
import 'package:clicli_grey/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = '';
  String pwd = '';
  bool isDo = false;

  _login() async {
    if (name.isEmpty || pwd.isEmpty) {
      showSnackBar('什么都没有输入');
      return;
    }
    showSnackBar('登录中···');
    setState(() {
      isDo = true;
    });
    final res = jsonDecode((await login({'name': name, 'pwd': pwd})).data);

    if (res['code'] != 200) {
      showErrorSnackBar(res['msg']);
      setState(() {
        isDo = false;
      });
    } else {
      setState(() {
        isDo = false;
      });
      Instances.sp.setString('usertoken', res['token']);
      Instances.sp.setString('userinfo', jsonEncode(res['user']));
      Instances.eventBus.fire(TriggerLogin());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/login_bg.webp'),
          ),
        ),
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                TextButton(
                  child: const Text('注册'),
                  onPressed: () {
                    launch('https://admin.clicli.me/register');
                  },
                )
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 6),
            Center(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 50),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          maxLines: 1,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration: InputDecoration(
                            labelText: '用户名',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          onChanged: (v) {
                            name = v;
                          },
                        ),
                        TextField(
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: '密码',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          obscureText: true,
                          onChanged: (v) {
                            pwd = v;
                          },
                        ),
                        const SizedBox(height: 20),
                        MaterialButton(
                          color: Theme.of(context).primaryColor,
                          child: const Text(
                            '登录',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: isDo ? null : _login,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
