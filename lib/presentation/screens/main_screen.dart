import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';
import 'transparent_png_screen.dart';
import '../providers/navigation_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);

    // 画面一覧
    final screens = [
      const CameraScreen(mode: CameraMode.normal),
      const CameraScreen(mode: CameraMode.overlay),
      const TransparentPngScreen(),
      const GalleryScreen(),
    ];

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(navigationProvider.notifier).setIndex(index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: '通常撮影',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'オーバーレイ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_fix_high),
            label: '透過PNG作成',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'ギャラリー',
          ),
        ],
      ),
    );
  }
}
