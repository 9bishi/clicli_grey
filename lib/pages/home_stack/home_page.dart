import 'dart:convert';

import 'package:clicli_grey/api/post.dart';
import 'package:clicli_grey/pages/rank_page.dart';
import 'package:clicli_grey/pages/search_page.dart';
import 'package:clicli_grey/service/events.dart';
import 'package:clicli_grey/widgets//post_card.dart';
import 'package:clicli_grey/widgets/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../instance.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const List<String> tabs = ["推荐", "最新"];

  late TabController _tabController;
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);
  final ScrollController _scrollController1 =
      ScrollController(keepScrollOffset: true);

  List<int> page = [1, 1];
  List _reList = [];
  List _newList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: tabs.length,
      vsync: this,
    );
    Instances.eventBus.on<MainButtonNavDoubleClickToTop>().listen((event) {
      if (event.key == MainStack.home) {
        [_scrollController, _scrollController1][_tabController.index].animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutSine);
      }
    });
  }

  Future<void> initLoad() async {
    page[_tabController.index] = 1;
    final res = (await getPost('', tabs[0], 1, 20)).data;
    _reList = jsonDecode(res)['posts'];
    setState(() {});
  }

  Future<void> initNewList() async {
    page[_tabController.index] = 1;
    final res1 = (await getPost('', '', 1, 20)).data;
    _newList = jsonDecode(res1)['posts'];
    setState(() {});
  }

  Future<bool> _loadData({reset = false}) async {
    String res;
    final index = _tabController.index;
    final _page = reset ? 1 : page[index] + 1;

    if (index == 0) {
      res = (await getPost('', tabs[0], _page, 15)).data;
    } else {
      res = (await getPost('', '', _page, 15)).data;
    }

    final List posts = jsonDecode(res)['posts'] ?? [];
    if (reset) {
      if (index == 0) {
        _reList = posts;
      } else {
        _newList = posts;
      }
      page[index] = 1;
    } else {
      if (index == 0) {
        _reList.addAll(posts);
      } else {
        _newList.addAll(posts);
      }
      page[index] = _page;
    }
    setState(() {});
    return posts.isNotEmpty;
  }

  void _to(BuildContext _, Widget w) {
    Navigator.push(_, MaterialPageRoute(builder: (__) => w));
  }

  get appbar => AppBar(
        backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: SvgPicture.asset(
                'assets/ic_ranking.svg',
                semanticsLabel: 'rank',
                color: const Color.fromRGBO(148, 107, 230, 1),
              ),
              onPressed: () {
                _to(context, const RankPage());
              },
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: const BoxDecoration(),
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
              labelColor: const Color.fromRGBO(148, 107, 230, 1),
              tabs: List.generate(
                tabs.length,
                (index) => Text(tabs[index]),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/Search.svg',
                height: 22,
                semanticsLabel: 'search',
                color: const Color.fromRGBO(148, 107, 230, 1),
              ),
              onPressed: () {
                _to(context, const SearchPage());
              },
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController1.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 245, 1),
      appBar: appbar,
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          RefreshWrapper(
            onLoadMore: _loadData,
            onRefresh: initLoad,
            scrollController: _scrollController,
            child: Grid2RowView(
              itemBuilder: (_, i) => PostCard(_reList[i]),
              controller: _scrollController,
              len: _reList.length,
            ),
          ),
          RefreshWrapper(
            onLoadMore: _loadData,
            onRefresh: initNewList,
            scrollController: _scrollController1,
            child: Grid2RowView(
              itemBuilder: (_, i) => PostCard(_newList[i]),
              controller: _scrollController1,
              len: _newList.length,
            ),
          ),
        ],
      ),
    );
  }
}
