import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/theme/app_shadows.dart';
import 'animated_scale_button.dart';

/// Purpose: A standard glassmorphism button.
/// Usage: Primary actions inside glass interfaces.
/// Parameters:
///   - [onPressed]: Callback when tapped.
///   - [child]: Button content (Text/Icon).
/// Example:
/// `dart
/// GlassButton(onPressed: () {}, child: Text("Submit"));
/// `
class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const GlassButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: AnimatedScaleButton(
        onPressed: onPressed,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardGlass,
            boxShadow: AppShadows.cardShadow,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.text,
              elevation: 0,
              splashFactory: NoSplash.splashFactory,
              overlayColor: Colors.transparent,
              minimumSize: const Size(56, 56), // Circle touch target
              shape: const CircleBorder(),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
