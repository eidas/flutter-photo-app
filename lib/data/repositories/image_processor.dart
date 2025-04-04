import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../domain/entities/overlay_image.dart';

class ImageProcessor {
  final List<OverlayImage> overlays;

  ImageProcessor(this.overlays);

  /// オーバーレイ情報をメタデータ用に取得
  List<Map<String, dynamic>> getOverlayInfo() {
    return overlays
        .map((overlay) => {
              'id': overlay.id,
              'path': overlay.path,
              'x': overlay.x,
              'y': overlay.y,
              'scale': overlay.scale,
              'rotation': overlay.rotation,
            })
        .toList();
  }

  /// カメラ画像とオーバーレイを合成した画像を作成
  Future<Uint8List> createCompositedImage(
      Uint8List photoData, Size viewSize) async {
    // カメラで撮影した画像をデコード
    final ui.Image capturedImage = await decodeImageFromList(photoData);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // カメラ画像を描画
    final photoRect = Rect.fromLTWH(0, 0, viewSize.width, viewSize.height);
    canvas.drawImageRect(
      capturedImage,
      Rect.fromLTWH(0, 0, capturedImage.width.toDouble(),
          capturedImage.height.toDouble()),
      photoRect,
      Paint(),
    );

    // オーバーレイを描画
    for (final overlay in overlays) {
      final overlayImage = await _loadOverlayImage(overlay.path);
      final overlayRect = Rect.fromLTWH(
        overlay.x,
        overlay.y,
        overlay.originalSize.width * overlay.scale,
        overlay.originalSize.height * overlay.scale,
      );

      canvas.save();
      canvas.translate(overlay.x + (overlayRect.width / 2),
          overlay.y + (overlayRect.height / 2));
      canvas.rotate(overlay.rotation);
      canvas.translate(-(overlay.x + (overlayRect.width / 2)),
          -(overlay.y + (overlayRect.height / 2)));

      canvas.drawImageRect(
        overlayImage,
        Rect.fromLTWH(0, 0, overlayImage.width.toDouble(),
            overlayImage.height.toDouble()),
        overlayRect,
        Paint(),
      );

      canvas.restore();
    }

    final ui.Image compositeImage = await recorder.endRecording().toImage(
          viewSize.width.toInt(),
          viewSize.height.toInt(),
        );

    final ByteData? byteData =
        await compositeImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List compositeData = byteData!.buffer.asUint8List();

    // JPEGに変換
    return await _convertToJpeg(compositeData);
  }

  /// 透過PNG生成処理
  Future<Uint8List> createTransparentPng(File image1, File image2) async {
    // 画像をデコード
    final bytes1 = await image1.readAsBytes();
    final bytes2 = await image2.readAsBytes();

    final img.Image? img1 = img.decodeImage(bytes1);
    final img.Image? img2 = img.decodeImage(bytes2);

    if (img1 == null || img2 == null) {
      throw Exception('Failed to decode images');
    }

    // 画像サイズが異なる場合はリサイズ
    img.Image processedImg1 = img1;
    img.Image processedImg2 = img2;

    if (img1.width != img2.width || img1.height != img2.height) {
      // 小さい方のサイズに合わせる
      final width = img1.width < img2.width ? img1.width : img2.width;
      final height = img1.height < img2.height ? img1.height : img2.height;

      processedImg1 = img.copyResize(img1, width: width, height: height);
      processedImg2 = img.copyResize(img2, width: width, height: height);
    }

    // 透過PNG作成
    final resultImage = img.Image(
      width: processedImg1.width,
      height: processedImg1.height,
      numChannels: 4,
    );

    // 各ピクセルの差分を計算して透明度を設定
    for (int y = 0; y < resultImage.height; y++) {
      for (int x = 0; x < resultImage.width; x++) {
        final pixel1 = processedImg1.getPixel(x, y);
        final pixel2 = processedImg2.getPixel(x, y);

        // final r1 = img.getRed(pixel1);
        // final g1 = img.getGreen(pixel1);
        // final b1 = img.getBlue(pixel1);

        // final r2 = img.getRed(pixel2);
        // final g2 = img.getGreen(pixel2);
        // final b2 = img.getBlue(pixel2);
        final r1 = pixel1.r;
        final g1 = pixel1.g;
        final b1 = pixel1.b;

        final r2 = pixel2.r;
        final g2 = pixel2.g;
        final b2 = pixel2.b;

        // 色の差分を計算
        final diffR = (r1 - r2).abs();
        final diffG = (g1 - g2).abs();
        final diffB = (b1 - b2).abs();

        // 差分の平均値
        final avgDiff = (diffR + diffG + diffB) / 3;

        // 差分が閾値を超える場合は不透明、それ以外は透明に
        int alpha = 0;
        if (avgDiff > 30) {
          alpha = 255; // 不透明

          // 画像1のピクセル色を使用
          // resultImage.setPixel(x, y, img.getColor(r1, g1, b1, alpha));
          resultImage.getPixel(x, y).setRgba(r1, g1, b1, alpha);
        } else {
          // 透明なピクセル
          // resultImage.setPixel(x, y, img.getColor(0, 0, 0, alpha));
          resultImage.getPixel(x, y).setRgba(0, 0, 0, alpha);
        }
      }
    }

    // ノイズ除去フィルタを適用
    final filteredImage = _applyNoiseFilter(resultImage);

    // 自動トリミング
    final trimmedImage = _autoTrim(filteredImage);

    // PNGとしてエンコード
    final pngData = img.encodePng(trimmedImage);
    return Uint8List.fromList(pngData);
  }

  // ヘルパーメソッド
  Future<ui.Image> _loadOverlayImage(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return await decodeImageFromList(bytes);
  }

  Future<Uint8List> _convertToJpeg(Uint8List pngData) async {
    final img.Image? image = img.decodeImage(pngData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  // ノイズ除去フィルタ
  img.Image _applyNoiseFilter(img.Image image) {
    // 孤立したピクセルを除去する簡易メディアンフィルタ
    final result = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 4,
    );

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final center = image.getPixel(x, y);
        // final centerAlpha = img.getAlpha(center);
        final centerAlpha = center.a;

        // 周囲8ピクセルのアルファ値を取得
        num alphaSum = 0;
        int alphaCount = 0;

        for (int ny = -1; ny <= 1; ny++) {
          for (int nx = -1; nx <= 1; nx++) {
            if (nx == 0 && ny == 0) continue;

            // final neighborAlpha = img.getAlpha(image.getPixel(x + nx, y + ny));
            final neighborAlpha = image.getPixel(x + nx, y + ny).a;
            alphaSum += neighborAlpha;
            alphaCount++;
          }
        }

        final avgAlpha = alphaSum / alphaCount;

        // 孤立ピクセル判定（中央が不透明で周囲のほとんどが透明、またはその逆）
        if ((centerAlpha > 200 && avgAlpha < 50) ||
            (centerAlpha < 50 && avgAlpha > 200)) {
          // 周囲の多数決に従う
          final newAlpha = avgAlpha > 127 ? 255 : 0;
          // result.setPixel(
          //     x,
          //     y,
          //     img.getColor(
          //       img.getRed(center),
          //       img.getGreen(center),
          //       img.getBlue(center),
          //       newAlpha,
          //     ));
          result.getPixel(x, y).setRgba(center.r, center.g, center.b, newAlpha);
        } else {
          result.setPixel(x, y, center);
        }
      }
    }

    return result;
  }

  // 自動トリミング
  img.Image _autoTrim(img.Image image) {
    // 不透明ピクセルの範囲を見つける
    int minX = image.width;
    int minY = image.height;
    int maxX = 0;
    int maxY = 0;

    bool hasOpaque = false;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        // final alpha = img.getAlpha(image.getPixel(x, y));
        final alpha = image.getPixel(x, y).a;
        if (alpha > 0) {
          hasOpaque = true;
          minX = minX < x ? minX : x;
          minY = minY < y ? minY : y;
          maxX = maxX > x ? maxX : x;
          maxY = maxY > y ? maxY : y;
        }
      }
    }

    // 不透明ピクセルがない場合は元の画像を返す
    if (!hasOpaque) {
      return image;
    }

    // 余白を追加（10ピクセル）
    final padding = 10;
    minX = minX - padding > 0 ? minX - padding : 0;
    minY = minY - padding > 0 ? minY - padding : 0;
    maxX = maxX + padding < image.width - 1 ? maxX + padding : image.width - 1;
    maxY =
        maxY + padding < image.height - 1 ? maxY + padding : image.height - 1;

    // 指定された範囲を切り出す
    final width = maxX - minX + 1;
    final height = maxY - minY + 1;

    return img.copyCrop(image, x: minX, y: minY, width: width, height: height);
  }
}
