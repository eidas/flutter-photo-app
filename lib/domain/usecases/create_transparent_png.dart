import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/transparent_png.dart';
import '../repositories/transparent_png_repository.dart';

/// 透過PNG作成に関するユースケース
class CreateTransparentPngUseCase {
  final TransparentPngRepository transparentPngRepository;

  CreateTransparentPngUseCase({
    required this.transparentPngRepository,
  });

  /// 2枚の画像から透過PNGを作成する
  /// 
  /// [image1]と[image2]の差分を抽出して透過PNGを生成します
  /// [threshold]は差分検出の閾値（デフォルト: 30）
  Future<TransparentPng> createFromImages(File image1, File image2, {int threshold = 30}) async {
    // 透過PNG生成
    final transparentPng = await transparentPngRepository.createTransparentPng(
      image1, 
      image2,
      threshold: threshold,
    );
    
    return transparentPng;
  }

  /// 画像から透過PNGを作成して保存する
  /// 
  /// 生成した透過PNGを保存し、オーバーレイとして使用可能にします
  Future<String> saveTransparentPng(Uint8List pngData) async {
    return await transparentPngRepository.saveTransparentPng(pngData);
  }
  
  /// デバイスのギャラリーから画像を選択する
  Future<File?> pickImage() async {
    return await transparentPngRepository.pickImage();
  }
  
  /// 透過PNGのプレビューを生成する
  ///
  /// 2枚の画像から透過PNGのプレビューを生成します。
  /// 実際の保存は行いません。
  Future<Uint8List> previewTransparentPng(File image1, File image2, {int threshold = 30}) async {
    return await transparentPngRepository.previewTransparentPng(image1, image2, threshold: threshold);
  }
}

/// CreateTransparentPngUseCase用のプロバイダー
final createTransparentPngUseCaseProvider = Provider<CreateTransparentPngUseCase>((ref) {
  final transparentPngRepository = ref.watch(transparentPngRepositoryProvider);
  
  return CreateTransparentPngUseCase(
    transparentPngRepository: transparentPngRepository,
  );
});
