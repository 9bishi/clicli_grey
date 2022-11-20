import 'dart:convert';
import 'package:clicli_grey/api/post.dart';
import 'package:clicli_grey/instance.dart';
import 'package:clicli_grey/pages/search_page.dart';
import 'package:clicli_grey/service/theme_manager.dart';
import 'package:clicli_grey/utils/date_util.dart';
import 'package:clicli_grey/utils/reg_utils.dart';
import 'package:clicli_grey/widgets/common_widget.dart';
import 'package:clicli_grey/widgets/empty_appbar.dart';
import 'package:clicli_grey/widgets/photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chewie/chewie.dart' hide MaterialControls;
import 'package:clicli_grey/widgets/clicli_video_control.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'package:clicli_grey/widgets/clicli_video_control.dart';

//https://stackoverflow.com/questions/52431109/flutter-video-player-fullscreen
class PlayerPage extends StatefulWidget with WidgetsBindingObserver {
  const PlayerPage({Key? key, required this.data, this.pos}) : super(key: key);

  final Map data;
  final int? pos;

  @override
  State<StatefulWidget> createState() {
    return _PlayerPageState();
  }
}

//https://vt1.doubanio.com/201902111139/0c06a85c600b915d8c9cbdbbaf06ba9f/view/movie/M/302420330.mp4
class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  TabController? _tabController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  List videoList = [];
  Map postDetail = {};
  int currPlayIndex = 0;
  List dataSourceList = [];

  getDetail() async {
    postDetail =
        jsonDecode((await getPostDetail(widget.data['id'])).data)['result'];

    var videos = postDetail['videos']?.split("\n");
    for (var video in videos) {
      var v = video.split("\$");
      videoList.add(v);
      dataSourceList.add(v[1]);
    }

    if (mounted) {
      setState(() async {
        if (videoList.isNotEmpty) {
          _tabController = TabController(length: 2, vsync: this);
          await initPlayer();
        }
      });
      widget.data['pv'] =
          jsonDecode((await getPV(widget.data['id'])).data)['result']['pv'];
      setState(() {});
    }
  }

  get _progressColors => ChewieProgressColors(
      playedColor: const Color.fromRGBO(148, 107, 230, 0.7),
      handleColor: const Color.fromRGBO(148, 107, 230, 1),
      backgroundColor: const Color.fromRGBO(240, 240, 245, 0.5),
      bufferedColor: const Color.fromRGBO(240, 240, 245, 1));

  initPlayer() async {
    var data = dataSourceList[currPlayIndex];

    var realData = jsonDecode((await getPlayUrl(data!)).data)['result'];

    var type = realData['mtype'];
    var url = realData['url'];
    // print(url);
    if (type! == 'm3u8') {
      _videoPlayerController =
          VideoPlayerController.network(url!, formatHint: VideoFormat.hls);
    } else {
      _videoPlayerController = VideoPlayerController.network(url!);
    }

    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        allowMuting: false,
        allowPlaybackSpeedChanging: false,
        customControls: const MaterialControls(
          showPlayButton: true,
        ),
        materialProgressColors: _progressColors);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    getDetail();
    getFollowBgi();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.data;
    double screenWidth = MediaQuery.of(context).size.width;
    double playerHeight = screenWidth / 16 * 9;
    return Scaffold(
        appBar: videoList.isEmpty
            ? AppBar(
                title: Text(
                  detail['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : const EmptyAppBar(),
        body: videoList.isNotEmpty && _chewieController != null
            ? Column(
                children: <Widget>[
                  Container(
                    width: screenWidth,
                    height: playerHeight,
                    color: Colors.grey,
                    child: Chewie(
                      controller: _chewieController!,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TabBar(
                        tabs: const <Widget>[Tab(text: '剧集'), Tab(text: '简介')],
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        isScrollable: true,
                        indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        indicatorColor:
                            Theme.of(context).primaryColor.withOpacity(.4),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ClipOval(
                          child: Image.network(
                            getAvatar(avatar: detail['uqq'] ?? ''),
                            width: 35,
                            height: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        buildProfile(context),
                        PlayerProfile(detail, videoList.isNotEmpty)
                      ],
                    ),
                  )
                ],
              )
            : PlayerProfile(detail, videoList.isNotEmpty));
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    Wakelock.disable();
    super.dispose();
  }

  bool hasFollowBgi = false;

  getFollowBgi() {
    final List o = jsonDecode(Instances.sp.getString('followBgi') ?? '[]');
    if (o.indexWhere((element) => element['id'] == widget.data['id']) != -1) {
      hasFollowBgi = true;
    }
  }

  followBgi() {
    // Instances.sp.remove('followBgi');
    final List o = jsonDecode(Instances.sp.getString('followBgi') ?? '[]');

    if (hasFollowBgi) {
      o.removeWhere((f) => f['id'] == widget.data['id']);
    } else {
      final historyInfo = {
        'thumb': getSuo(widget.data['content']),
        'name': widget.data['title'],
        'id': widget.data['id'],
        'data': widget.data,
        'create_time': DateTime.now().millisecondsSinceEpoch
      };
      o.add(historyInfo);
    }

    hasFollowBgi = !hasFollowBgi;
    Instances.sp.setString('followBgi', jsonEncode(o));
    setState(() {});
  }

  Widget buildProfile(BuildContext context) {
    final detail = widget.data;
    final theme = Theme.of(context);
    final caption = theme.textTheme.caption!;
    final List tags = detail['tag']?.substring(1).split(' ');
    final time = getTimeDistance(detail['time']);

    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(child: ellipsisText(detail['title'])),
              ElevatedButton(
                onPressed: followBgi,
                child: Text(
                  hasFollowBgi ? '已追番' : '追番',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('gv${detail['id']}  ', style: caption),
              Text('$time ', style: caption),
              SvgPicture.asset('assets/Fire.svg', width: 12),
              Text(
                ' ${detail['pv']?.toString() ?? '∞'} ℃',
                style: caption.copyWith(
                    color: const Color.fromRGBO(245, 191, 8, 1)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            for (int i = 0; i < tags.length; i++)
              if (tags[i].length > 0)
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            TagPage(tags[i] as String)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      tags[i],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
          ]),
          const SizedBox(height: 10),
          buildVideoList()
        ]);
  }

  Widget buildVideoList() {
    final color = Theme.of(context).primaryColor;
    return Column(
        children: List.generate(videoList.length, (int i) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: InkWell(
            splashColor: color.withOpacity(0.6),
            highlightColor: color.withOpacity(0.4),
            onTap: () {
              if (i != currPlayIndex) {
                currPlayIndex = i;
                initPlayer();
                setState(() {});
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                color: i == currPlayIndex
                    ? color.withOpacity(0.5)
                    : color.withOpacity(0.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: <Widget>[
                  Text(
                    ' $i.  ',
                    style: TextStyle(color: color),
                  ),
                  Expanded(
                    child: ellipsisText(
                      '${videoList[i][0]}',
                      style: TextStyle(color: color),
                    ),
                  ),
                ],
              ),
            )),
      );
    }));
  }
}

class PlayerProfile extends StatefulWidget {
  const PlayerProfile(this.detail, this.needTitle, {Key? key})
      : super(key: key);

  final Map detail;
  final bool needTitle;

  @override
  State<StatefulWidget> createState() => _PlayerProfile();
}

class _PlayerProfile extends State<PlayerProfile>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final detail = widget.detail;
    final i = detail['content'].indexOf('# 播放出错');
    final content =
        i < 0 ? detail['content'] : detail['content'].substring(0, i);
    final meta = widget.needTitle ? '# ${detail['title']}  ' : '';
    return SingleChildScrollView(
        padding: widget.needTitle
            ? const EdgeInsets.fromLTRB(10, 0, 10, 10)
            : const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!widget.needTitle) ...[
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: ClipOval(
                  child: Image.network(
                    getAvatar(avatar: detail['uqq']),
                    width: 40,
                    height: 40,
                  ),
                ),
                title: ListBody(
                  children: [
                    Text(
                      '${detail['uname'] ?? ''}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      getTimeDistance('${detail['time']}'),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                detail['title'].trim(),
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "GV${detail['id']}".toString(),
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: ThemeManager.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  SvgPicture.asset('assets/Fire.svg', width: 12),
                  Text(
                    ' ${detail['pv']?.toString() ?? '∞'} ℃',
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: const Color.fromRGBO(245, 191, 8, 1)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            MarkdownBody(
              // selectable: true,
              data: meta + content,
              onTapLink: (url, _, __) => launch(url),
              styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
              imageBuilder: (Uri uri, String? title, String? alt) =>
                  GestureDetector(
                onTap: () {
                  Navigator.of(context).push(CliCliiPhotoViewGallery.getRoute(
                    initialIndex: 0,
                    photos: [uri.toString()],
                  ));
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  child: Hero(
                    tag: uri.toString(),
                    child: Image.network(uri.toString(), width: double.infinity,
                        loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 66,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              styleSheet: MarkdownStyleSheet(
                blockquotePadding: const EdgeInsets.only(left: 6),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 1.5,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                // https://github.com/flutter/flutter/issues/81720
                blockquote:
                    const TextStyle(fontSize: 14, color: Colors.black54),
                code: const TextStyle(fontFamily: "Source Code Pro"),
                a: TextStyle(color: Theme.of(context).primaryColor),
                p: ThemeManager.isDark()
                    ? const TextStyle(fontSize: 14, color: Colors.white)
                    : const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ));
  }
}
