import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/transparent_png_repository.dart';
import '../../data/repositories/image_processor.dart';

/// 透過PNG生成に使用する画像のステータス
enum TransparentPngImageStatus {
  notSelected,    // 画像未選択
  firstSelected,  // 1枚目選択済み
  secondSelected, // 2枚目選択済み
  processing,     // 処理中
  completed,      // 処理完了
  error,          // エラー発生
}

/// 透過PNG生成状態を管理するNotifier
class TransparentPngNotifier extends StateNotifier<TransparentPngImageStatus> {
  TransparentPngNotifier() : super(TransparentPngImageStatus.notSelected);
  
  File? _firstImage;
  File? _secondImage;
  Uint8List? _resultPngData;
  String? _errorMessage;
  
  // ゲッター
  File? get firstImage => _firstImage;
  File? get secondImage => _secondImage;
  Uint8List? get resultPngData => _resultPngData;
  String? get errorMessage => _errorMessage;
  
  /// 1枚目の画像を選択
  Future<void> selectFirstImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _firstImage = File(pickedFile.path);
      state = TransparentPngImageStatus.firstSelected;
    }
  }
  
  /// 2枚目の画像を選択
  Future<void> selectSecondImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _secondImage = File(pickedFile.path);
      state = TransparentPngImageStatus.secondSelected;
    }
  }
  
  /// 透過PNG生成処理を実行
  Future<void> createTransparentPng(ImageProcessor imageProcessor) async {
    if (_firstImage == null || _secondImage == null) {
      _errorMessage = "2枚の画像が必要です";
      state = TransparentPngImageStatus.error;
      return;
    }
    
    state = TransparentPngImageStatus.processing;
    
    try {
      _resultPngData = await imageProcessor.createTransparentPng(
        _firstImage!,
        _secondImage!,
      );
      state = TransparentPngImageStatus.completed;
    } catch (e) {
      _errorMessage = e.toString();
      state = TransparentPngImageStatus.error;
    }
  }
  
  /// 状態をリセット
  void reset() {
    _firstImage = null;
    _secondImage = null;
    _resultPngData = null;
    _errorMessage = null;
    state = TransparentPngImageStatus.notSelected;
  }
}

/// 透過PNG生成用リポジトリプロバイダー
final transparentPngRepositoryProvider = Provider<TransparentPngRepository>((ref) {
  throw UnimplementedError('transparentPngRepositoryProvider has not been initialized');
});

/// 画像処理プロバイダー
final imageProcessorProvider = Provider<ImageProcessor>((ref) {
  return ImageProcessor();
});

/// 透過PNG生成プロバイダー
final transparentPngProvider = StateNotifierProvider<TransparentPngNotifier, TransparentPngImageStatus>((ref) {
  return TransparentPngNotifier();
});

/// 処理結果の透過PNGを提供するプロバイダー
final resultTransparentPngProvider = Provider<Uint8List?>((ref) {
  final status = ref.watch(transparentPngProvider);
  if (status == TransparentPngImageStatus.completed) {
    return ref.watch(transparentPngProvider.notifier).resultPngData;
  }
  return null;
});

/// エラーメッセージを提供するプロバイダー
final transparentPngErrorProvider = Provider<String?>((ref) {
  final status = ref.watch(transparentPngProvider);
  if (status == TransparentPngImageStatus.error) {
    return ref.watch(transparentPngProvider.notifier).errorMessage;
  }
  return null;
});

/// 選択された2枚の画像を提供するプロバイダー
final selectedImagesProvider = Provider<(File?, File?)>((ref) {
  final notifier = ref.watch(transparentPngProvider.notifier);
  return (notifier.firstImage, notifier.secondImage);
});
