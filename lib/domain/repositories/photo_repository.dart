import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../entities/photo.dart';

/// PhotoRepository - 写真撮影と管理に関する操作を定義するリポジトリインターフェース
abstract class PhotoRepository {
  /// 通常写真を撮影する
  Future<Photo> takePhoto();

  /// オーバーレイ合成写真を撮影する
  /// 
  /// [viewSize] カメラビューのサイズ
  Future<Photo> takeOverlayPhoto(Size viewSize);

  /// 全ての写真を取得する
  Future<List<Photo>> getAllPhotos();

  /// 写真の種類に基づいてフィルタリングされた写真リストを取得する
  /// 
  /// [type] 取得する写真の種類
  Future<List<Photo>> getPhotosByType(PhotoType type);

  /// 写真を削除する
  /// 
  /// [photoId] 削除する写真のID
  Future<void> deletePhoto(String photoId);

  /// 写真を共有する
  /// 
  /// [photoPath] 共有する写真のパス
  Future<void> sharePhoto(String photoPath);
}
