import 'dart:convert';

import 'package:clicli_grey/instance.dart';
import 'package:clicli_grey/pages/player_page.dart';
import 'package:clicli_grey/widgets/common_widget.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List hisList = [];

  @override
  void initState() {
    super.initState();
    getHis();
  }

  Future<void> getHis() async {
    setState(() {
      final List _hisList =
          jsonDecode(Instances.sp.getString('history') ?? '[]');
      _hisList.sort((p, n) => n['create_time'].compareTo(p['create_time']));
      hisList = _hisList;
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height / 8;
    final w = MediaQuery.of(context).size.width / 3;
    final color = Theme.of(context).cardColor;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('历史记录'),
      ),
      body: RefreshIndicator(
        child: ListView.builder(
          itemBuilder: (_, i) {
            return GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return PlayerPage(
                      data: hisList[i]['data'], pos: hisList[i]['curr']);
                }), (Route<dynamic> route) => true);
              },
              child: Container(
                  color: color,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(5),
                  height: size,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Image.network(
                          hisList[i]['thumb'],
                          fit: BoxFit.cover,
                          width: w,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ellipsisText(hisList[i]['name']),
                            const SizedBox(height: 5),
                            Text('第 ${hisList[i]['curr'] ?? 0 + 1} 集'),
                            if (hisList[i]['create_time'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  '${DateTime.fromMillisecondsSinceEpoch(hisList[i]['create_time']).toLocal()}',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              )
                          ],
                        ),
                      )
                    ],
                  )),
            );
          },
          itemCount: hisList.length,
        ),
        onRefresh: getHis,
      ),
    );
  }
}
