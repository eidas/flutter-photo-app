import 'dart:typed_data';
import '../entities/photo.dart';

/// StorageRepository - 写真と透過PNGの保存と管理に関する操作を定義するリポジトリインターフェース
abstract class StorageRepository {
  /// 写真をデバイスのストレージに保存する
  /// 
  /// [photoData] 保存する写真データ (JPEG形式)
  /// [metadata] 写真に関連付けるメタデータ
  /// [saveToGallery] デバイスのギャラリーにも保存するかどうか
  Future<String> savePhoto(
    Uint8List photoData,
    PhotoMetadata metadata, {
    bool saveToGallery = true,
  });

  /// 透過PNGをデバイスのストレージに保存する
  /// 
  /// [pngData] 保存する透過PNG形式の画像データ
  /// [metadata] 透過PNGに関連付けるメタデータ
  /// [saveToGallery] デバイスのギャラリーにも保存するかどうか
  Future<String> saveTransparentPng(
    Uint8List pngData,
    PhotoMetadata metadata, {
    bool saveToGallery = true,
  });

  /// 保存されている全ての写真を取得する
  Future<List<Photo>> getAllPhotos();

  /// 写真をIDに基づいて削除する
  /// 
  /// [photoId] 削除する写真のID
  Future<void> deletePhoto(String photoId);
}
