import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final bool isOverlayMode;
  final VoidCallback onCapture;
  
  const CameraControls({
    Key? key,
    required this.isOverlayMode,
    required this.onCapture,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 撮影ボタン
          GestureDetector(
            onTap: onCapture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                color: Colors.white24,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
