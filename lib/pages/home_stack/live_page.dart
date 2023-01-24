import 'dart:convert';

import 'package:clicli_grey/api/post.dart';
import 'package:clicli_grey/instance.dart';
import 'package:clicli_grey/service/events.dart';
import 'package:clicli_grey/widgets//post_card.dart';
import 'package:clicli_grey/widgets/refresh.dart';
import 'package:flutter/material.dart';

class LivePage extends StatefulWidget {
  const LivePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LivePageState();
  }
}

class _LivePageState extends State<LivePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  List data = [];
  int page = 1;

  Future<bool> getUGC() async {
    final res = jsonDecode((await getPost('推流', '', page, 20)).data)['posts'];
    if (res?.isNotEmpty) {
      setState(() {
        data.addAll(res);
      });
    }
    page += 1;
    return res?.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<MainButtonNavDoubleClickToTop>().listen((event) {
      if (event.key == MainStack.ugc) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutSine);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
          automaticallyImplyLeading: false,
          title: const Text('推流', style: TextStyle(fontSize: 24, color: Color.fromRGBO(148, 107, 230, 1))),
          centerTitle: false,
        ),
        body: RefreshWrapper(
          onLoadMore: getUGC,
          onRefresh: getUGC,
          scrollController: _scrollController,
          child: Grid2RowView(
            controller: _scrollController,
            itemBuilder: (_, i) => PostCard(data[i]),
            len: data.length,
          ),
        ));
  }
}
