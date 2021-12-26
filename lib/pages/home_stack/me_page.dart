import 'dart:convert';

import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/service/events.dart';
import 'package:clicli_dark/utils/version_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class MePage extends StatefulWidget {
  const MePage({Key? key}) : super(key: key);

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<TriggerLogin>().listen((e) {
      getLocalProfile();
    });

    getLocalProfile();
  }

  Map? userInfo;

  getLocalProfile() {
    final u = Instances.sp.getString('userinfo');
    userInfo = u != null
        ? jsonDecode(u)
        : {'name': '点击登录', 'desc': '这个人很酷，没有签名', 'qq': '1'};
    setState(() {});
  }

  bool isDarkTheme = Instances.sp.getBool('isDarkTheme') ?? false;

  toggleDarkMode({bool? val}) {
    if (val == null) {
      isDarkTheme = !isDarkTheme;
      Instances.eventBus.fire(ChangeTheme(isDarkTheme));
      Instances.sp.setBool('isDarkTheme', isDarkTheme);
    } else {
      setState(() {
        isDarkTheme = val;
        Instances.eventBus.fire(ChangeTheme(val));
        Instances.sp.setBool('isDarkTheme', val);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ctx = Theme.of(context);
    return Scaffold(
        backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
          automaticallyImplyLeading: false,
          title: const Text('个人', style: TextStyle(fontSize: 24,color: Color.fromRGBO(148, 107, 230, 1))),
        ),
        body: ListView(
          children: <Widget>[
            ListBody(
              children: <Widget>[
                ListTile(
                  leading: SizedBox(
                    height: double.infinity,
                    child: SvgPicture.asset(
                      isDarkTheme ? 'assets/Moon.svg' : 'assets/Sunny.svg',
                      width: 25,
                    ),
                  ),
                  title: const Text('暗黑模式'),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      activeColor: ctx.primaryColor,
                      value: isDarkTheme,
                      onChanged: (bool val) {
                        toggleDarkMode(val: val);
                      },
                    ),
                  ),
                  onTap: toggleDarkMode,
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/周.svg',
                    width: 25,
                  ),
                  title: const Text('追番'),
                  onTap: () {
                    Navigator.pushNamed(context, 'CliCli://fav');
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/qq.svg',
                    width: 25,
                  ),
                  title: const Text('投稿大队'),
                  onTap: () => launch('https://jq.qq.com/?_wv=1027&k=5lfSD1B'),
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/系统更新.svg',
                    width: 25,
                  ),
                  title: const Text('检查更新'),
                  onTap: checkAppUpdate,
                )
              ],
            ),
            GestureDetector(
              onTap: () => launch('https://jq.qq.com/?_wv=1027&k=5lfSD1B'),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20),
                child: Text(
                  'APP VERSION ${Instances.appVersion}',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
          ],
        ));
  }
}
