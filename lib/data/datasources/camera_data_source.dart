import 'dart:typed_data';
import 'package:camera/camera.dart';

/// カメラ操作を抽象化するデータソースインターフェース
abstract class CameraDataSource {
  /// カメラを初期化する
  Future<void> initialize();
  
  /// カメラのプレビューストリームを取得する
  Stream<CameraImage> getPreviewStream();
  
  /// 写真を撮影し、バイナリデータとして返す
  Future<Uint8List> capturePhoto();
  
  /// カメラリソースを解放する
  Future<void> dispose();
}

/// カメラデータソースの実装クラス
class CameraDataSourceImpl implements CameraDataSource {
  late CameraController _cameraController;
  final CameraDescription _camera;
  
  /// コンストラクタ：カメラ情報を受け取る
  CameraDataSourceImpl(this._camera);
  
  @override
  Future<void> initialize() async {
    _cameraController = CameraController(
      _camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg, // 明示的な形式指定
    );
    await _cameraController.initialize();
  }
  
  @override
  Stream<CameraImage> getPreviewStream() {
    return _cameraController.startImageStream();
  }
  
  @override
  Future<Uint8List> capturePhoto() async {
    final XFile file = await _cameraController.takePicture();
    return await file.readAsBytes();
  }
  
  @override
  Future<void> dispose() async {
    await _cameraController.dispose();
  }
}
