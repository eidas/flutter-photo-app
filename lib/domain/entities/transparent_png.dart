import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'photo.dart';

class TransparentPng {
  final String id;
  final String path;
  final Uint8List data;
  final Size size;
  final PhotoMetadata metadata;
  
  TransparentPng({
    required this.id,
    required this.path,
    required this.data,
    required this.size,
    required this.metadata,
  });
  
  factory TransparentPng.fromPhoto(Photo photo, Uint8List data, Size size) {
    return TransparentPng(
      id: photo.id,
      path: photo.path,
      data: data,
      size: size,
      metadata: photo.metadata,
    );
  }
  
  TransparentPng copyWith({
    String? id,
    String? path,
    Uint8List? data,
    Size? size,
    PhotoMetadata? metadata,
  }) {
    return TransparentPng(
      id: id ?? this.id,
      path: path ?? this.path,
      data: data ?? this.data,
      size: size ?? this.size,
      metadata: metadata ?? this.metadata,
    );
  }
}

class TransparentPngCreationResult {
  final TransparentPng transparentPng;
  final String savedPath;
  final bool addedToOverlays;

  TransparentPngCreationResult({
    required this.transparentPng,
    required this.savedPath,
    required this.addedToOverlays,
  });
}

class TransparentPngSettings {
  final int threshold;
  final bool applyNoiseFilter;
  final bool autoTrim;
  final int padding;
  
  const TransparentPngSettings({
    this.threshold = 30,
    this.applyNoiseFilter = true,
    this.autoTrim = true,
    this.padding = 10,
  });
  
  TransparentPngSettings copyWith({
    int? threshold,
    bool? applyNoiseFilter,
    bool? autoTrim,
    int? padding,
  }) {
    return TransparentPngSettings(
      threshold: threshold ?? this.threshold,
      applyNoiseFilter: applyNoiseFilter ?? this.applyNoiseFilter,
      autoTrim: autoTrim ?? this.autoTrim,
      padding: padding ?? this.padding,
    );
  }
}