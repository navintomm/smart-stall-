import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// Purpose: A customized transparent app bar for glass interfaces.
/// Usage: Use as the AppBar for screens.
/// Parameters:
///   - [title]: Screen title.
/// Example:
/// `dart
/// Scaffold(appBar: CustomAppBar(title: 'Home'));
/// `
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.displayLarge.copyWith(fontSize: 24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
