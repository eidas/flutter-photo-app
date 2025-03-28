import 'package:flutter/material.dart';

class OverlayImage {
  final String id;
  final String path;
  final double x;
  final double y;
  final double scale;
  final double rotation;
  final Size originalSize;
  
  OverlayImage({
    required this.id,
    required this.path,
    this.x = 0.0,
    this.y = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    required this.originalSize,
  });
  
  OverlayImage copyWith({
    String? id,
    String? path,
    double? x,
    double? y,
    double? scale,
    double? rotation,
    Size? originalSize,
  }) {
    return OverlayImage(
      id: id ?? this.id,
      path: path ?? this.path,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      originalSize: originalSize ?? this.originalSize,
    );
  }
}
