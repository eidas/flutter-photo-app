import 'dart:typed_data';
import 'package:camera/camera.dart';

/// CameraRepository - カメラデバイスを操作するためのリポジトリインターフェース
abstract class CameraRepository {
  /// カメラを初期化する
  Future<void> initialize();
  
  /// カメラプレビューのストリームを取得する
  Stream<CameraImage> getPreviewStream();
  
  /// 写真を撮影する
  Future<Uint8List> capturePhoto();
  
  /// カメラリソースを解放する
  Future<void> dispose();
}
