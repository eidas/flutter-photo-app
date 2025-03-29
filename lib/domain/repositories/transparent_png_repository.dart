import 'dart:io';
import 'dart:typed_data';

/// TransparentPngRepository - 透過PNG画像の作成と管理に関する操作を定義するリポジトリインターフェース
abstract class TransparentPngRepository {
  /// 2枚の画像から透過PNGを生成する
  ///
  /// [image1] 背景を含む元の画像
  /// [image2] 被写体のみの画像
  Future<Uint8List> createTransparentPng(File image1, File image2);

  /// 生成した透過PNGを保存し、必要に応じてオーバーレイリストに追加する
  ///
  /// [pngData] 保存する透過PNG形式の画像データ
  Future<String> saveTransparentPng(Uint8List pngData);

  pickImage() {}

  previewTransparentPng(File image1, File image2, {required int threshold}) {}
}
