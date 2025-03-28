import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// データソース
import 'data/datasources/camera_data_source.dart';
import 'data/datasources/gallery_data_source.dart';
import 'data/datasources/local_storage_data_source.dart';

// リポジトリ
import 'domain/repositories/photo_repository.dart';
import 'domain/repositories/storage_repository.dart';
import 'data/repositories/photo_repository_impl.dart';
import 'data/repositories/storage_repository_impl.dart';
import 'data/repositories/image_processor.dart';

// プロバイダー
import 'presentation/providers/camera_provider.dart';
import 'presentation/providers/gallery_provider.dart';
import 'presentation/providers/overlay_provider.dart';

/// アプリの依存関係注入を設定する
void setupDependencies(ProviderContainer container) {
  // データソース
  final cameraDataSourceProvider = Provider<CameraDataSource>((ref) {
    final cameras = ref.watch(availableCamerasProvider).maybeWhen(
          data: (cameras) => cameras,
          orElse: () => <CameraDescription>[],
        );
    
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }
    
    return CameraDataSourceImpl(cameras.first);
  });
  
  final galleryDataSourceProvider = Provider<GalleryDataSource>((ref) {
    return GalleryDataSourceImpl();
  });
  
  final localStorageDataSourceProvider = Provider<LocalStorageDataSource>((ref) {
    return LocalStorageDataSourceImpl();
  });
  
  // リポジトリ
  final storageRepositoryProvider = Provider<StorageRepository>((ref) {
    final localStorageDataSource = ref.watch(localStorageDataSourceProvider);
    return StorageRepositoryImpl(localStorageDataSource);
  });
  
  // 画像処理プロセッサ
  final imageProcessorProvider = Provider<ImageProcessor>((ref) {
    final overlays = ref.watch(overlayManagerProvider);
    return ImageProcessor(overlays);
  });
  
  // 写真リポジトリ
  container.updateOverrides([
    photoRepositoryProvider.overrideWith((ref) {
      final cameraDataSource = ref.watch(cameraDataSourceProvider);
      final storageDataSource = ref.watch(localStorageDataSourceProvider);
      final imageProcessor = ref.watch(imageProcessorProvider);
      
      return PhotoRepositoryImpl(
        cameraDataSource: cameraDataSource,
        storageDataSource: storageDataSource,
        imageProcessor: imageProcessor,
      );
    }),
  ]);
}
