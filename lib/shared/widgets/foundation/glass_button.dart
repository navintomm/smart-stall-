import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.largeRadius,
          color: AppColors.cardGlass,
          border: Border.all(color: AppColors.borderLight, width: 1.0),
          boxShadow: AppShadows.cardShadow,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.text,
            elevation: 0,
            minimumSize: const Size(48, 48), // Accessibility touch target
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.largeRadius,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
