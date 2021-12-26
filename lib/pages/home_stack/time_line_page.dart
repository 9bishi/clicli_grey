import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/widgets//post_card.dart';
import 'package:flutter/material.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TimeLineState();
  }
}

class _TimeLineState extends State<TimeLinePage> {
  static const List week = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  List<List> data = [[], [], [], [], [], [], []];

  Future<Object> getUGC() async {
    data = [[], [], [], [], [], [], []];
    final res = (await getPost('新番', '', 1, 100)).data;
    final List _res = jsonDecode(res)['posts'];

    for (var f in _res) {
      final t = f['time'] + ''.replaceAll('-', '/');
      final day = DateTime.parse(t).weekday - 1;

      data[day].add(f);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
        title: const Text(
          'TIME LINE',
          style:
              TextStyle(fontSize: 24, color: Color.fromRGBO(148, 107, 230, 1)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          for (int i = 0; i < data.length; i++)
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    week[i],
                    style: theme.textTheme.headline6!
                        .copyWith(color: theme.primaryColor),
                  ),
                ),
                for (int j = 0;
                    j <
                        ((data[i].length % 2 > 0)
                            ? data[i].length ~/ 2 + 1
                            : data[i].length ~/ 2);
                    j++)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                          child: PostCard(data[i][j * 2]),
                        ),
                      ),
                      data[i].length > j * 2 + 1
                          ? Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                                child: PostCard(data[i][j * 2 + 1]),
                              ),
                            )
                          : Expanded(child: Container())
                    ],
                  )
              ],
            )
        ],
      ),
    );
  }
}
