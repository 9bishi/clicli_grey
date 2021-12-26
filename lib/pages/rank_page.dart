import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/pages/player_page.dart';
import 'package:clicli_dark/utils/reg_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RankPage extends StatefulWidget {
  const RankPage({Key? key}) : super(key: key);

  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List rankList = [];

  Future<Object> getRankInfo() async {
    rankList = jsonDecode((await getRank()).data)['posts'];
    return rankList;
  }

  toPlay(dynamic data) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => PlayerPage(data: data)));

  @override
  Widget build(BuildContext context) => Scaffold(
          body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  getSuo(rankList.isNotEmpty ? rankList[0]['content'] : ''),
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                'THE HOT TOP 10',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
          body: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: rankList.length,
            itemBuilder: (ctx, i) {
              return GestureDetector(
                onTap: () => toPlay(rankList[i]),
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: IntrinsicHeight(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 120),
                            child: Image(
                              image:
                                  NetworkImage(getSuo(rankList[i]['content'])),
                              width: MediaQuery.of(context).size.width / 4,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                rankList[i]['title'].trimLeft(),
                                style: Theme.of(context).textTheme.subtitle1!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                rankList[i]['sort'],
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              Text(
                                rankList[i]['tag'].trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        MaterialButton(
                          onPressed: () => toPlay(rankList[i]),
                          minWidth: 30,
                          child: SvgPicture.asset(
                            'assets/play_outline.svg',
                            color: Theme.of(context).primaryColor,
                            width: 25,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}
