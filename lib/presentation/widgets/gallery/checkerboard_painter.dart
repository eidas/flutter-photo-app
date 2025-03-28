import 'package:flutter/material.dart';

/// チェック柄の背景を描画するカスタムペインター
class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 8.0;
    final paint = Paint()..color = Colors.grey.shade300;
    
    for (int i = 0; i < size.width / cellSize; i++) {
      for (int j = 0; j < size.height / cellSize; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
