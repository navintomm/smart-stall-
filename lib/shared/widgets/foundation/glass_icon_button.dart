import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/theme/app_shadows.dart';

/// Purpose: A glassmorphism icon button.
/// Usage: Icon actions inside glass interfaces.
/// Parameters:
///   - [onPressed]: Callback when tapped.
///   - [icon]: Icon widget.
/// Example:
/// `dart
/// GlassIconButton(onPressed: () {}, icon: Icon(Icons.add));
/// `
class GlassIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;

  const GlassIconButton({super.key, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardGlass,
          shape: BoxShape.circle,
          boxShadow: AppShadows.cardShadow,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          color: AppColors.primary,
          splashRadius: 24,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Min touch target
        ),
      ),
    );
  }
}
