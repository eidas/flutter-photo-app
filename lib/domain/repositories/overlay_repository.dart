import '../entities/overlay_image.dart';

/// OverlayRepository - オーバーレイ画像の管理と操作に関する操作を定義するリポジトリインターフェース
abstract class OverlayRepository {
  /// 現在管理されているオーバーレイ画像のリストを取得する
  List<OverlayImage> getOverlays();

  /// 新しいオーバーレイ画像を追加する
  /// 
  /// [overlay] 追加するオーバーレイ画像
  void addOverlay(OverlayImage overlay);

  /// 指定されたIDのオーバーレイ画像を削除する
  /// 
  /// [id] 削除するオーバーレイ画像のID
  void removeOverlay(String id);

  /// 指定されたIDのオーバーレイ画像を更新する
  /// 
  /// [id] 更新するオーバーレイ画像のID
  /// [x] 新しいX座標位置（省略可）
  /// [y] 新しいY座標位置（省略可）
  /// [scale] 新しい拡大縮小率（省略可）
  /// [rotation] 新しい回転角度（省略可）
  void updateOverlay(
    String id, {
    double? x,
    double? y,
    double? scale,
    double? rotation,
  });

  /// 全てのオーバーレイ画像をクリアする
  void clearOverlays();
}
