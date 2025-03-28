import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/screens/main_screen.dart';

// 名前付きルート定義用
class AppRoutes {
  static const String home = '/';
  static const String gallery = '/gallery';
  static const String photoDetail = '/photo-detail';
}

// ルート生成用関数
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const MainScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Route ${settings.name} not found')),
        ),
      );
  }
}
