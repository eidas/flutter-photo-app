import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'dependency_injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  setupDependencies(container);
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PhotoApp(),
    ),
  );
}
