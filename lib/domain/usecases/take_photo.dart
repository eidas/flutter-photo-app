import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/photo.dart';
import '../entities/overlay_image.dart';
import '../repositories/photo_repository.dart';
import '../repositories/camera_repository.dart';

/// 写真撮影に関するユースケース
class TakePhotoUseCase {
  final PhotoRepository photoRepository;
  final CameraRepository cameraRepository;

  TakePhotoUseCase({
    required this.photoRepository,
    required this.cameraRepository,
  });

  /// 通常の写真を撮影する
  Future<Photo> takePhoto() async {
    // カメラが初期化されていなければ初期化
    if (!await cameraRepository.isInitialized()) {
      await cameraRepository.initialize();
    }
    
    // 写真を撮影して返す
    return await photoRepository.takePhoto();
  }

  /// オーバーレイ付きの写真を撮影する
  Future<Photo> takeOverlayPhoto(List<OverlayImage> overlays, Size viewSize) async {
    // カメラが初期化されていなければ初期化
    if (!await cameraRepository.isInitialized()) {
      await cameraRepository.initialize();
    }
    
    // オーバーレイ付きの写真を撮影して返す
    return await photoRepository.takeOverlayPhoto(overlays, viewSize);
  }
}

/// TakePhotoUseCase用のプロバイダー
final takePhotoUseCaseProvider = Provider<TakePhotoUseCase>((ref) {
  final photoRepository = ref.watch(photoRepositoryProvider);
  final cameraRepository = ref.watch(cameraRepositoryProvider);
  
  return TakePhotoUseCase(
    photoRepository: photoRepository,
    cameraRepository: cameraRepository,
  );
});
