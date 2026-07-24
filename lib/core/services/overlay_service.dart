import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

class OverlayService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void showSnackBar(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          margin: const EdgeInsets.all(AppSpacing.md),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<T?> showCustomDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return Future.value(null);

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  Future<T?> showCustomBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return Future.value(null);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }
}
