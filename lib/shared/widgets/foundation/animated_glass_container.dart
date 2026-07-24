import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/glass_effects.dart';

/// Purpose: A reusable animated glass container for Soft Glassmorphism effects.
/// Usage: Use as a base for custom glass cards or surfaces.
/// Parameters:
///   - [child]: The content of the container.
///   - [opacity]: The opacity level of the glass.
/// Example:
/// `dart
/// AnimatedGlassContainer(child: Text("Hello"));
/// `
class AnimatedGlassContainer extends StatelessWidget {
  final Widget child;
  final double opacity;
  final BorderRadiusGeometry? borderRadius;

  const AnimatedGlassContainer({
    super.key,
    required this.child,
    this.opacity = GlassEffects.opacity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.largeRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: GlassEffects.blur, sigmaY: GlassEffects.blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: AppColors.cardGlass.withOpacity(opacity),
            borderRadius: borderRadius ?? AppRadius.largeRadius,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

