import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_provider.dart';
import '../providers/overlay_provider.dart';
import '../widgets/camera/camera_preview_widget.dart';
import '../widgets/camera/camera_controls.dart';
import '../widgets/overlay/overlay_canvas.dart';

class CameraScreen extends ConsumerWidget {
  final CameraMode mode;
  
  const CameraScreen({Key? key, required this.mode}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // カメラモードを設定
    ref.read(cameraModeProvider.notifier).state = mode;
    
    // カメラコントローラーを取得
    final cameraController = ref.watch(cameraControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == CameraMode.normal ? '通常撮影' : 'オーバーレイ撮影'),
        actions: [
          if (mode == CameraMode.overlay)
            IconButton(
              icon: const Icon(Icons.layers_clear),
              onPressed: () {
                ref.read(overlayManagerProvider.notifier).clearOverlays();
              },
              tooltip: 'オーバーレイをクリア',
            ),
        ],
      ),
      body: cameraController.when(
        data: (controller) => Stack(
          children: [
            // カメラプレビュー
            CameraPreviewWidget(controller: controller),
            
            // オーバーレイモードの場合はオーバーレイを表示
            if (mode == CameraMode.overlay)
              const OverlayCanvas(),
            
            // カメラコントロール
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CameraControls(
                isOverlayMode: mode == CameraMode.overlay,
                onCapture: () => _handleCapture(context, ref, controller),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('カメラの初期化に失敗しました: $error'),
        ),
      ),
    );
  }
  
  Future<void> _handleCapture(BuildContext context, WidgetRef ref, controller) async {
    try {
      // 撮影ボタンを押した時の処理
      final photoRepository = ref.read(photoRepositoryProvider);
      
      if (mode == CameraMode.normal) {
        // 通常撮影
        await photoRepository.takePhoto();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('写真を保存しました')),
        );
      } else {
        // オーバーレイ撮影
        final size = MediaQuery.of(context).size;
        await photoRepository.takeOverlayPhoto(size);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('オーバーレイ付き写真を保存しました')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }
}
