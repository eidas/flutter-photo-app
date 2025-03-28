import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/photo.dart';
import 'checkerboard_painter.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  final Function(Photo) onPhotoTap;

  const PhotoGrid({
    Key? key,
    required this.photos,
    required this.onPhotoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoThumbnail(
          photo: photo,
          onTap: () => onPhotoTap(photo),
        );
      },
    );
  }
}

class PhotoThumbnail extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;

  const PhotoThumbnail({
    Key? key,
    required this.photo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 透過PNG用の背景をチェック柄で表示
    final bool isTransparent = photo.metadata.type == PhotoType.transparentPng;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: photo.id,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isTransparent) CustomPaint(painter: CheckerboardPainter()),
              Image.file(
                File(photo.path),
                fit: BoxFit.cover,
              ),
              Positioned(
                right: 4.0,
                bottom: 4.0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Icon(
                    _getIconForPhotoType(photo.metadata.type),
                    size: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForPhotoType(PhotoType type) {
    switch (type) {
      case PhotoType.normal:
        return Icons.photo;
      case PhotoType.overlay:
        return Icons.layers;
      case PhotoType.transparentPng:
        return Icons.image;
      default:
        return Icons.image;
    }
  }
}
