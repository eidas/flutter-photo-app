import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../data/datasources/camera_data_source.dart';
import '../../domain/repositories/camera_repository.dart';

/// 利用可能なカメラのリストを提供するプロバイダー
final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

/// カメラデータソースプロバイダー
final cameraDataSourceProvider = Provider.family<CameraDataSource, CameraDescription>((ref, camera) {
  return CameraDataSourceImpl(camera);
});

/// カメラリポジトリプロバイダー
/// CameraRepository型のインスタンスを提供する
/// 実際のカメラリポジトリの実装はコンストラクタインジェクションで提供される
final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  throw UnimplementedError('cameraRepositoryProvider has not been initialized');
});

/// カメラコントローラープロバイダー
/// カメラのプレビューと写真撮影に使用するCameraControllerを提供する
final cameraControllerProvider = FutureProvider.autoDispose<CameraController>((ref) async {
  // 利用可能なカメラを取得
  final cameras = await ref.watch(availableCamerasProvider.future);
  
  // カメラが存在しない場合はエラーをスロー
  if (cameras.isEmpty) {
    throw Exception('No cameras available');
  }
  
  // デフォルトで最初のカメラ（通常は背面カメラ）を使用
  final camera = cameras.first;
  
  // カメラコントローラーを初期化
  final controller = CameraController(
    camera,
    ResolutionPreset.high,
    enableAudio: false,
    imageFormatGroup: ImageFormatGroup.jpeg,
  );
  
  // コントローラーを初期化
  await controller.initialize();
  
  // プロバイダーが破棄されたときに確実にリソースを解放
  ref.onDispose(() {
    controller.dispose();
  });
  
  return controller;
});

/// 選択中のカメラモード
enum CameraMode {
  normal,   // 通常撮影モード
  overlay,  // オーバーレイ撮影モード
}

/// 現在のカメラモードを管理するプロバイダー
final cameraModeProvider = StateProvider<CameraMode>((ref) {
  return CameraMode.normal; // デフォルトは通常モード
});
