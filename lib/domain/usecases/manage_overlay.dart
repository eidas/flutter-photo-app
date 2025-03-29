import 'dart:io';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/overlay_image.dart';
import '../repositories/overlay_repository.dart';

/// オーバーレイ操作に関するユースケース
class ManageOverlayUseCase {
  final OverlayRepository overlayRepository;
  
  ManageOverlayUseCase({
    required this.overlayRepository,
  });
  
  /// 現在のオーバーレイのリストを取得する
  List<OverlayImage> getOverlays() {
    return overlayRepository.getOverlays();
  }
  
  /// 指定されたパスの画像をオーバーレイとして追加する
  Future<OverlayImage> addOverlay(String path) async {
    return await overlayRepository.addOverlay(path);
  }
  
  /// 指定されたIDのオーバーレイを削除する
  void removeOverlay(String id) {
    overlayRepository.removeOverlay(id);
  }
  
  /// オーバーレイの位置とサイズを更新する
  void updateOverlay(
    String id, {
    double? x,
    double? y,
    double? scale,
    double? rotation,
  }) {
    overlayRepository.updateOverlay(
      id,
      x: x,
      y: y,
      scale: scale,
      rotation: rotation,
    );
  }
  
  /// 全てのオーバーレイをクリアする
  void clearOverlays() {
    overlayRepository.clearOverlays();
  }
  
  /// オーバーレイを指定位置にリセットする
  void resetOverlayPosition(String id, {required Size viewSize}) {
    // 画面の中央に配置
    final x = viewSize.width / 2;
    final y = viewSize.height / 2;
    
    overlayRepository.updateOverlay(
      id,
      x: x,
      y: y,
      scale: 1.0,
      rotation: 0.0,
    );
  }
  
  /// オーバーレイのファイルを別の形式（PNG/JPEG）に変換する
  Future<File> convertOverlayFormat(String id, String format) async {
    if (format != 'png' && format != 'jpeg') {
      throw ArgumentError('Format must be either "png" or "jpeg"');
    }
    
    return await overlayRepository.convertOverlayFormat(id, format);
  }
  
  /// オーバーレイの透明度を調整する（PNG形式のみ）
  Future<OverlayImage> adjustOverlayTransparency(String id, double opacity) async {
    if (opacity < 0.0 || opacity > 1.0) {
      throw ArgumentError('Opacity must be between 0.0 and 1.0');
    }
    
    return await overlayRepository.adjustOverlayTransparency(id, opacity);
  }
  
  /// デバイスのギャラリーから画像をオーバーレイとして読み込む
  Future<OverlayImage?> importOverlayFromGallery() async {
    return await overlayRepository.importFromGallery();
  }
}

/// ManageOverlayUseCase用のプロバイダー
final manageOverlayUseCaseProvider = Provider<ManageOverlayUseCase>((ref) {
  final overlayRepository = ref.watch(overlayRepositoryProvider);
  
  return ManageOverlayUseCase(
    overlayRepository: overlayRepository,
  );
});
