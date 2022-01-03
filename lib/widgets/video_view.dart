import 'package:chewie/chewie.dart' hide MaterialControls;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// import 'hi_video_controls.dart';

class VideoView extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;
  final double aspectRatio;

  const VideoView(this.url,
      {Key? key,
      this.autoPlay = false,
      this.looping = false,
      this.aspectRatio = 16 / 9,})
      : super(key: key);

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController? _videoPlayerController; //video_player播放器Controller
  ChewieController? _chewieController; //chewie播放器Controller

  //进度条颜色配置
  get _progressColors => ChewieProgressColors(
      playedColor: const Color.fromRGBO(148, 107, 230, 0.7),
      handleColor: const Color.fromRGBO(148, 107, 230, 1),
      backgroundColor: const Color.fromRGBO(240, 240, 245, 0.5),
      bufferedColor: const Color.fromRGBO(240, 240, 245, 1));

  @override
  void initState() {
    super.initState();
    //初始化播放器设置
    _videoPlayerController = VideoPlayerController.network(widget.url);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: widget.aspectRatio,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        allowMuting: false,
        allowPlaybackSpeedChanging: false,
        materialProgressColors: _progressColors);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double playerHeight = screenWidth / widget.aspectRatio;
    return Container(
      width: screenWidth,
      height: playerHeight,
      color: Colors.grey,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}
