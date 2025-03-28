import 'dart:typed_data';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/local_storage_data_source.dart';

class StorageRepositoryImpl implements StorageRepository {
  final LocalStorageDataSource localStorageDataSource;
  
  StorageRepositoryImpl(this.localStorageDataSource);
  
  @override
  Future<String> savePhoto(
    Uint8List photoData,
    PhotoMetadata metadata, {
    bool saveToGallery = true,
  }) async {
    return await localStorageDataSource.savePhoto(
      photoData, 
      metadata, 
      saveToGallery: saveToGallery
    );
  }
  
  @override
  Future<String> saveTransparentPng(
    Uint8List pngData,
    PhotoMetadata metadata, {
    bool saveToGallery = true,
  }) async {
    return await localStorageDataSource.saveTransparentPng(
      pngData, 
      metadata, 
      saveToGallery: saveToGallery
    );
  }
  
  @override
  Future<List<Photo>> getAllPhotos() async {
    return await localStorageDataSource.getAllPhotos();
  }
  
  @override
  Future<void> deletePhoto(String photoId) async {
    await localStorageDataSource.deletePhoto(photoId);
  }
}
