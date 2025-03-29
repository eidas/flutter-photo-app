import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/overlay_image.dart';
import '../../domain/repositories/overlay_repository.dart';

/// オーバーレイリポジトリのプロバイダー
/// 実際の実装はmain.dartなどで依存性注入される
final overlayRepositoryProvider = Provider<OverlayRepository>((ref) {
  throw UnimplementedError('overlayRepositoryProvider has not been initialized');
});

/// オーバーレイ画像の状態を管理するNotifier
class OverlayManagerNotifier extends StateNotifier<List<OverlayImage>> {
  OverlayManagerNotifier() : super([]);

  /// 新しいオーバーレイ画像を追加
  void addOverlay(OverlayImage overlay) {
    if (state.length < 10) { // 最大10個までに制限
      state = [...state, overlay];
    }
  }

  /// 指定されたIDのオーバーレイ画像を削除
  void removeOverlay(String id) {
    state = state.where((overlay) => overlay.id != id).toList();
  }

  /// オーバーレイ画像の位置、サイズ、角度を更新
  void updateOverlay(String id, {double? x, double? y, double? scale, double? rotation}) {
    state = state.map((overlay) {
      if (overlay.id == id) {
        return overlay.copyWith(
          x: x,
          y: y,
          scale: scale,
          rotation: rotation,
        );
      }
      return overlay;
    }).toList();
  }

  /// 全てのオーバーレイをクリア
  void clearOverlays() {
    state = [];
  }
  
  /// 指定されたインデックスのオーバーレイを選択状態にする
  void selectOverlay(String id) {
    state = state.map((overlay) {
      if (overlay.id == id) {
        return overlay.copyWith(isSelected: true);
      } else {
        // 他のオーバーレイの選択状態を解除
        return overlay.copyWith(isSelected: false);
      }
    }).toList();
  }
  
  /// 全てのオーバーレイの選択状態を解除
  void clearSelection() {
    state = state.map((overlay) => overlay.copyWith(isSelected: false)).toList();
  }
}

/// オーバーレイ管理プロバイダー
/// オーバーレイ画像のリストとその操作を提供
final overlayManagerProvider = StateNotifierProvider<OverlayManagerNotifier, List<OverlayImage>>((ref) {
  return OverlayManagerNotifier();
});

/// 現在選択中のオーバーレイ画像を提供するプロバイダー
final selectedOverlayProvider = Provider<OverlayImage?>((ref) {
  final overlays = ref.watch(overlayManagerProvider);
  return overlays.firstWhere((overlay) => overlay.isSelected, orElse: () => null);
});

/// オーバーレイの表示状態を管理するプロバイダー
final overlayVisibilityProvider = StateProvider<bool>((ref) => true);
