import 'dart:convert';

import 'package:clicli_grey/instance.dart';
import 'package:clicli_grey/pages/player_page.dart';
import 'package:clicli_grey/widgets/common_widget.dart';
import 'package:flutter/material.dart';

class BgiPage extends StatefulWidget {
  const BgiPage({Key? key}) : super(key: key);

  @override
  _BgiPageState createState() => _BgiPageState();
}

class _BgiPageState extends State<BgiPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List bgiList = [];
  List hisList = [];

  @override
  void initState() {
    super.initState();
    getBgi();
  }

  Future<void> getBgi() async {
    setState(() {
      final List _bgiList =
          jsonDecode(Instances.sp.getString('followBgi') ?? '[]');
      _bgiList.sort((p, n) => n['create_time'].compareTo(p['create_time']));
      bgiList = _bgiList;
      hisList = jsonDecode(Instances.sp.getString('history') ?? '[]');
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  removeItem(DismissDirection _, int i) {
    if (_ == DismissDirection.endToStart) {
      bgiList.removeAt(i);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Text('（￣︶￣）↗　'),
        ),
      );
      Instances.sp.setString('followBgi', jsonEncode(bgiList));
    }
  }

  _toPlay(int i, int? curr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          data: bgiList[i]['data'],
          pos: curr,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final h = mq.size.height;
    final size = h / 6;
    final w = mq.size.width / 4;
    final color = theme.cardColor;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
        iconTheme: IconThemeData(
          color: Color.fromRGBO(148, 107, 230, 1), //修改颜色
        ),
        title: const Text(
          '追番',
          style:
              TextStyle(fontSize: 24, color: Color.fromRGBO(148, 107, 230, 1)),
        ),
      ),
      body: RefreshIndicator(
        child: ListView.builder(
          itemBuilder: (_, i) {
            final jj = hisList.firstWhere(
                (element) => element['id'] == bgiList[i]['id'],
                orElse: () => {'curr': 0});
            return Dismissible(
              direction: DismissDirection.endToStart,
              key: Key('key_$i'),
              onDismissed: (DismissDirection _) => removeItem(_, i),
              child: GestureDetector(
                onTap: () => _toPlay(i, jj['curr']),
                child: Container(
                    color: color,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    height: size,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Image.network(
                            bgiList[i]['thumb'],
                            fit: BoxFit.cover,
                            width: w,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ellipsisText(bgiList[i]['name']),
                              const SizedBox(height: 10),
                              Text("已观看到第 ${jj['curr'] + 1} 集"),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            );
          },
          itemCount: bgiList.length,
        ),
        onRefresh: getBgi,
      ),
    );
  }
}
