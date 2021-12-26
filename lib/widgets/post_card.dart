import 'package:cached_network_image/cached_network_image.dart';
import 'package:clicli_dark/pages/player_page.dart';
import 'package:clicli_dark/utils/reg_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PostCard extends StatefulWidget {
  final Map data;
  const PostCard(this.data, {Key? key}) : super(key: key);

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin {
  get data => widget.data;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return PlayerPage(data: data);
        }), (Route<dynamic> route) => true);
      },
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: getSuo(data['content']),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(height: 123),
                  height: 200,
                ),
                Container(
                  height: 202,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(1.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      data['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      data['tag'].substring(1).replaceAll(' ', ' · '),
                      style: Theme.of(context).textTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Grid2RowView extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final int len;

  const Grid2RowView({
    required this.itemBuilder,
    required this.len,
    this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      addAutomaticKeepAlives: true,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 6.0,
      crossAxisCount: 2,
      itemCount: len,
      padding: const EdgeInsets.all(4),
      itemBuilder: (context, index) {
        return itemBuilder(context, index);
      },
      controller: controller,
    );
  }
}
