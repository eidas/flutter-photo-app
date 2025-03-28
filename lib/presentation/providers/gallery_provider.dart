import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';

// リポジトリプロバイダー（実際の依存関係注入はmain.dartなどで行う）
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  throw UnimplementedError();
});

// ギャラリープロバイダー
final galleryProvider = FutureProvider.family<List<Photo>, PhotoType>((ref, type) async {
  final photoRepository = ref.watch(photoRepositoryProvider);
  
  if (type == PhotoType.all) {
    return photoRepository.getAllPhotos();
  }
  
  return photoRepository.getPhotosByType(type);
});

// 選択中の写真を管理するプロバイダー
final selectedPhotoProvider = StateProvider<Photo?>((ref) => null);
