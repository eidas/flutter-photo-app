import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../datasources/camera_data_source.dart';
import '../datasources/local_storage_data_source.dart';
import 'image_processor.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final CameraDataSource cameraDataSource;
  final LocalStorageDataSource storageDataSource;
  final ImageProcessor imageProcessor;
  
  PhotoRepositoryImpl({
    required this.cameraDataSource,
    required this.storageDataSource,
    required this.imageProcessor,
  });
  
  @override
  Future<Photo> takePhoto() async {
    final photoData = await cameraDataSource.capturePhoto();
    
    // 写真のメタデータを作成
    final metadata = PhotoMetadata(
      createdAt: DateTime.now(),
      type: PhotoType.normal,
    );
    
    // 写真をデバイスに保存
    final savedPhotoPath = await storageDataSource.savePhoto(
      photoData, 
      metadata,
      saveToGallery: true
    );
    
    return Photo(
      id: savedPhotoPath.split('/').last.split('.').first,
      path: savedPhotoPath,
      metadata: metadata,
    );
  }
  
  @override
  Future<Photo> takeOverlayPhoto(Size viewSize) async {
    final photoData = await cameraDataSource.capturePhoto();
    final compositedImage = await imageProcessor.createCompositedImage(photoData, viewSize);
    
    // 写真のメタデータを作成
    final metadata = PhotoMetadata(
      createdAt: DateTime.now(),
      type: PhotoType.overlay,
      overlayInfo: imageProcessor.getOverlayInfo(),
    );
    
    // 写真をデバイスに保存
    final savedPhotoPath = await storageDataSource.savePhoto(
      compositedImage, 
      metadata,
      saveToGallery: true
    );
    
    return Photo(
      id: savedPhotoPath.split('/').last.split('.').first,
      path: savedPhotoPath,
      metadata: metadata,
    );
  }
  
  @override
  Future<List<Photo>> getAllPhotos() async {
    return await storageDataSource.getAllPhotos();
  }
  
  @override
  Future<List<Photo>> getPhotosByType(PhotoType type) async {
    final allPhotos = await getAllPhotos();
    return allPhotos.where((photo) => photo.metadata.type == type).toList();
  }
  
  @override
  Future<void> deletePhoto(String photoId) async {
    await storageDataSource.deletePhoto(photoId);
  }
  
  @override
  Future<void> sharePhoto(String photoPath) async {
    final file = File(photoPath);
    if (await file.exists()) {
      await Share.shareFiles([photoPath]);
    }
  }
}
