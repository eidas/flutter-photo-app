import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/photo.dart';

abstract class LocalStorageDataSource {
  Future<String> savePhoto(Uint8List photoData, PhotoMetadata metadata, {bool saveToGallery = true});
  Future<String> saveTransparentPng(Uint8List pngData, PhotoMetadata metadata, {bool saveToGallery = true});
  Future<List<Photo>> getAllPhotos();
  Future<void> deletePhoto(String photoId);
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  final String _appDirName = AppConstants.appDirName;
  final String _metadataFileName = AppConstants.metadataFileName;
  
  Future<Directory> get _appDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/$_appDirName');
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }
  
  Future<File> get _metadataFile async {
    final dir = await _appDir;
    return File('${dir.path}/$_metadataFileName');
  }
  
  // メタデータをJSONとして保存
  Future<void> _saveMetadata(Map<String, dynamic> metadata) async {
    final file = await _metadataFile;
    final jsonString = jsonEncode(metadata);
    await file.writeAsString(jsonString);
  }
  
  // メタデータをJSONから読み込み
  Future<Map<String, dynamic>> _loadMetadata() async {
    final file = await _metadataFile;
    
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    
    return {'photos': {}};
  }
  
  @override
  Future<String> savePhoto(
    Uint8List photoData,
    PhotoMetadata metadata, {
    bool saveToGallery = true,
  }) async {
    final dir = await _appDir;
    final photoId = const Uuid().v4();
    final photoPath = '${dir.path}/$photoId.jpg';
    
    // アプリ内ストレージに保存
    final file = File(photoPath);
    await file.writeAsBytes(photoData);
    
    // メタデータに写真情報を追加
    final allMetadata = await _loadMetadata();
    final photos = allMetadata['photos'] as Map<String, dynamic>? ?? {};
    
    photos[photoId] = {
      'path': photoPath,
      'metadata': metadata.toJson(),
    };
    
    allMetadata['photos'] = photos;
    await _saveMetadata(allMetadata);
    
    // デバイスのギャラリーにも保存（オプション）
    if (saveToGallery) {
      final result = await ImageGallerySaver.saveImage(
        photoData,
        quality: AppConstants.imageQuality,
        name: 'PhotoApp_${metadata.type.toString()}_$photoId',
      );
    }
    
    return photoPath;
  }
  
  @override
  Future<String> saveTransparentPng(
    Uint8List pngData,
    PhotoMetadata metadata, {
    bool saveToGallery = true,
  }) async {
    final dir = await _appDir;
    final photoId = const Uuid().v4();
    final photoPath = '${dir.path}/$photoId.png';
    
    // アプリ内ストレージに保存
    final file = File(photoPath);
    await file.writeAsBytes(pngData);
    
    // メタデータに写真情報を追加
    final allMetadata = await _loadMetadata();
    final photos = allMetadata['photos'] as Map<String, dynamic>? ?? {};
    
    photos[photoId] = {
      'path': photoPath,
      'metadata': metadata.toJson(),
    };
    
    allMetadata['photos'] = photos;
    await _saveMetadata(allMetadata);
    
    // デバイスのギャラリーにも保存（オプション）
    if (saveToGallery) {
      final result = await ImageGallerySaver.saveImage(
        pngData,
        quality: 100,
        name: 'PhotoApp_TransparentPNG_$photoId',
      );
    }
    
    return photoPath;
  }
  
  @override
  Future<List<Photo>> getAllPhotos() async {
    final allMetadata = await _loadMetadata();
    final photos = allMetadata['photos'] as Map<String, dynamic>? ?? {};
    
    final List<Photo> result = [];
    
    for (final entry in photos.entries) {
      final id = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final path = data['path'] as String;
      final metadata = PhotoMetadata.fromJson(data['metadata']);
      
      // 確認：ファイルが実際に存在するか
      final file = File(path);
      if (await file.exists()) {
        result.add(Photo(
          id: id,
          path: path,
          metadata: metadata,
        ));
      }
    }
    
    // 日付の新しい順にソート
    result.sort((a, b) => b.metadata.createdAt.compareTo(a.metadata.createdAt));
    
    return result;
  }
  
  @override
  Future<void> deletePhoto(String photoId) async {
    final allMetadata = await _loadMetadata();
    final photos = allMetadata['photos'] as Map<String, dynamic>? ?? {};
    
    if (photos.containsKey(photoId)) {
      final photoData = photos[photoId] as Map<String, dynamic>;
      final path = photoData['path'] as String;
      
      // ファイル削除
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      
      // メタデータから削除
      photos.remove(photoId);
      allMetadata['photos'] = photos;
      await _saveMetadata(allMetadata);
    }
  }
}
