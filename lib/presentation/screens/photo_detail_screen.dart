import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/overlay_image.dart';
import '../../domain/entities/photo.dart';
import '../providers/gallery_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/overlay_provider.dart';
import '../widgets/gallery/checkerboard_painter.dart';

class PhotoDetailScreen extends ConsumerWidget {
  final Photo photo;

  const PhotoDetailScreen({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isTransparent = photo.metadata.type == PhotoType.transparentPng;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPhotoTypeTitle(photo.metadata.type)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePhoto(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
          if (isTransparent)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: () => _useAsOverlay(context, ref),
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: photo.id,
            child: Stack(
              children: [
                if (isTransparent)
                  CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: CheckerboardPainter(),
                  ),
                Image.file(
                  File(photo.path),
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPhotoTypeTitle(PhotoType type) {
    switch (type) {
      case PhotoType.normal:
        return '通常写真';
      case PhotoType.overlay:
        return 'オーバーレイ写真';
      case PhotoType.transparentPng:
        return '透過PNG';
      default:
        return '写真';
    }
  }

  Future<void> _sharePhoto(BuildContext context, WidgetRef ref) async {
    try {
      final photoRepository = ref.read(photoRepositoryProvider);
      await photoRepository.sharePhoto(photo.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('共有に失敗しました: $e')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('写真を削除'),
        content: const Text('この写真を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final photoRepository = ref.read(photoRepositoryProvider);
        await photoRepository.deletePhoto(photo.id);
        // 削除成功時は前の画面に戻る
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  void _useAsOverlay(BuildContext context, WidgetRef ref) {
    if (photo.metadata.type == PhotoType.transparentPng) {
      // デバイスから画像サイズを取得する処理
      final imageProvider = Image.file(File(photo.path)).image;
      imageProvider.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          final size = Size(
            info.image.width.toDouble(), 
            info.image.height.toDouble()
          );
          
          // オーバーレイとして追加
          ref.read(overlayManagerProvider.notifier).addOverlay(
            OverlayImage(
              id: const Uuid().v4(),
              path: photo.path,
              originalSize: size,
            ),
          );
          
          // オーバーレイモードのカメラ画面に移動
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('オーバーレイとして設定しました')),
          );
          
          // 前の画面に戻り、カメラオーバーレイモードに遷移
          Navigator.of(context).popUntil((route) => route.isFirst);
          ref.read(navigationProvider.notifier).setIndex(1); // オーバーレイモードのインデックス
        }),
      );
    }
  }
}
