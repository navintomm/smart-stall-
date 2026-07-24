import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

/// Purpose: A reusable glass card for displaying content.
/// Usage: Use as a container for grouped information.
/// Parameters:
///   - [child]: The content of the card.
///   - [padding]: Optional padding.
/// Example:
/// `dart
/// GlassCard(child: Text("Data"));
/// `
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardGlass.withOpacity(0.7),
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: AppShadows.cardShadow,
      ),
      child: child,
    );
  }
}
