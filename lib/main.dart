import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_gradients.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SmartStallApp(),
    ),
  );
}

class SmartStallApp extends StatelessWidget {
  const SmartStallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartStall Operator',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.backgroundGradient,
          ),
          child: child,
        );
      },
    );
  }
}
