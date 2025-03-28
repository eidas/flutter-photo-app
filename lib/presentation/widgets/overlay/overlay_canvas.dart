import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/overlay_provider.dart';
import 'overlay_image_widget.dart';

class OverlayCanvas extends ConsumerWidget {
  const OverlayCanvas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayImages = ref.watch(overlayManagerProvider);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Stack(
        children: [
          for (final overlay in overlayImages)
            OverlayImageWidget(
              key: Key(overlay.id),
              overlay: overlay,
              onUpdate: (updatedOverlay) {
                ref.read(overlayManagerProvider.notifier).updateOverlay(
                  overlay.id,
                  x: updatedOverlay.x,
                  y: updatedOverlay.y,
                  scale: updatedOverlay.scale,
                  rotation: updatedOverlay.rotation,
                );
              },
              onTap: () {
                ref.read(selectedOverlayIdProvider.notifier).state = overlay.id;
              },
            ),
        ],
      ),
    );
  }
}
