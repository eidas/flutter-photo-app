import 'package:flutter_riverpod/flutter_riverpod.dart';

// ナビゲーション状態の管理
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);
  
  void setIndex(int index) {
    state = index;
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
