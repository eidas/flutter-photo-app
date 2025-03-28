import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/overlay_image.dart';

class OverlayImageWidget extends StatefulWidget {
  final OverlayImage overlay;
  final Function(OverlayImage) onUpdate;
  final VoidCallback? onTap;
  
  const OverlayImageWidget({
    Key? key,
    required this.overlay,
    required this.onUpdate,
    this.onTap,
  }) : super(key: key);
  
  @override
  State<OverlayImageWidget> createState() => _OverlayImageWidgetState();
}

class _OverlayImageWidgetState extends State<OverlayImageWidget> {
  late OverlayImage _overlay;
  
  @override
  void initState() {
    super.initState();
    _overlay = widget.overlay;
  }
  
  @override
  void didUpdateWidget(OverlayImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overlay != widget.overlay) {
      _overlay = widget.overlay;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _overlay.x,
      top: _overlay.y,
      child: GestureDetector(
        onTap: widget.onTap,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: Transform.rotate(
          angle: _overlay.rotation,
          child: Transform.scale(
            scale: _overlay.scale,
            child: Image.file(
              File(_overlay.path),
              width: _overlay.originalSize.width,
              height: _overlay.originalSize.height,
            ),
          ),
        ),
      ),
    );
  }
  
  Offset? _startOffset;
  double? _startScale;
  double? _startRotation;
  
  void _onScaleStart(ScaleStartDetails details) {
    _startOffset = Offset(_overlay.x, _overlay.y);
    _startScale = _overlay.scale;
    _startRotation = _overlay.rotation;
  }
  
  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (details.pointerCount == 1) {
        // 移動操作
        _overlay = _overlay.copyWith(
          x: _startOffset!.dx + details.focalPointDelta.dx,
          y: _startOffset!.dy + details.focalPointDelta.dy,
        );
      } else if (details.pointerCount >= 2) {
        // 拡大縮小と回転
        _overlay = _overlay.copyWith(
          scale: (_startScale! * details.scale).clamp(0.1, 3.0),
          rotation: _startRotation! + details.rotation,
        );
      }
    });
  }
  
  void _onScaleEnd(ScaleEndDetails details) {
    widget.onUpdate(_overlay);
  }
}
