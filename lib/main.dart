import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/root/presentation/root_page.dart';
import 'core/di/providers.dart';

void main() {
  runApp(ProviderScope(overrides: overrideProviders, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beatify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootPage(),
    );
  }
}

