import 'package:clicli_dark/widgets/empty_appbar.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CliCliiPhotoViewGallery extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  static MaterialPageRoute getRoute(
      {required int initialIndex, required List<String> photos}) {
    return MaterialPageRoute(
      builder: (_) => CliCliiPhotoViewGallery(
        initialIndex: initialIndex,
        photos: photos,
      ),
    );
  }

  const CliCliiPhotoViewGallery({
    required this.photos,
    this.initialIndex = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
              child: PhotoViewGallery.builder(
            itemCount: photos.length,
            builder: (_, index) => PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(photos[index]),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              heroAttributes: PhotoViewHeroAttributes(tag: photos[index]),
              onTapDown: (context, __, ___) => Navigator.pop(context),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          )),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Text(
              photos[initialIndex],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
