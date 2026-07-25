import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

/// A premium glassmorphism card wrapped in a ClipRRect with BackdropFilter.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool animateEntrance;
  final Duration delay;

  const GlassCard({
    super.key, 
    required this.child, 
    this.padding,
    this.animateEntrance = false,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.largeRadius,
        boxShadow: AppShadows.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.largeRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24.0), // increased padding
            decoration: BoxDecoration(
              gradient: AppColors.glassGradient,
              borderRadius: AppRadius.largeRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (!animateEntrance) return card;

    // Simple implicit entrance animation if requested
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: card,
    );
  }
}
