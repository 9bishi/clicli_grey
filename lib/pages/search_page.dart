import 'dart:async';
import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/widgets/empty_appbar.dart';
import 'package:clicli_dark/widgets/loading2load.dart';
import 'package:clicli_dark/widgets/post_card.dart';
import 'package:clicli_dark/widgets/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  List? data;
  String? key;
  bool isLoading = false;

  final Duration durationTime = const Duration(milliseconds: 500);
  Timer? timer;

  Future<void> _loadData({reset = false}) async {
    if (key!.isEmpty) {
      data = [];
      return;
    }

    setState(() {
      isLoading = true;
    });

    dynamic res;
    if (int.tryParse(key!) != null) {
      res = jsonDecode((await getPostDetail(int.parse(key!))).data)['result'];
      if (res != null) data = [res];
    } else {
      res = (await getSearch(key)).data;
      if (reset) {
        data = jsonDecode(res)['posts'] ?? [];
      } else {
        data!.addAll(jsonDecode(res)['posts']);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(color: Theme.of(context).primaryColor),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(5),
            color: Theme.of(context).cardColor,
            child: Container(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.all(2),
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      maxLines: 1,
                      // maxLengthEnforced: true,
                      autofocus: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      onChanged: (v) {
                        key = v;
                        timer?.cancel();
                        timer = Timer(durationTime, () {
                          _loadData(reset: true);
                        });
                      },
                      inputFormatters: [LengthLimitingTextInputFormatter(15)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (data != null)
            Expanded(
                child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: isLoading
                  ? Center(child: loadingWidget)
                  : data!.isNotEmpty
                      ? Grid2RowView(
                          itemBuilder: (_, i) => PostCard(data![i]),
                          len: data!.length,
                        )
                      : Center(
                          child: Text(
                          '这里什么都没有 (⊙x⊙)',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                          ),
                        )),
            ))
        ],
      ),
    );
  }
}

class TagPage extends StatefulWidget {
  final String tag;

  const TagPage(this.tag, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  final ScrollController _scrollController = ScrollController();

  List data = [];
  int page = 1;

  Future<bool> getTagList() async {
    final List posts =
        jsonDecode((await getPost('', widget.tag, page, 15)).data)['posts'];
    data.addAll(posts);
    setState(() {});
    return posts.isNotEmpty;
  }

  Future<bool> getNextList() async {
    page = page + 1;
    return await getTagList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag, style: const TextStyle(fontSize: 24)),
      ),
      body: RefreshWrapper(
        scrollController: _scrollController,
        onRefresh: getTagList,
        onLoadMore: getNextList,
        child: Grid2RowView(
          controller: _scrollController,
          itemBuilder: (_, i) => PostCard(data[i]),
          len: data.length,
        ),
      ),
    );
  }
}
