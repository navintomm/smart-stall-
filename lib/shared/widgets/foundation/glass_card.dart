import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import 'animated_scale_button.dart';

/// A premium glassmorphism card wrapped in a ClipRRect with BackdropFilter.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool animateEntrance;
  final Duration delay;
  final VoidCallback? onTap;

  const GlassCard({
    super.key, 
    required this.child, 
    this.padding,
    this.animateEntrance = false,
    this.delay = Duration.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.cardGlass, // Pure white
        borderRadius: AppRadius.largeRadius,
        boxShadow: AppShadows.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      card = AnimatedScaleButton(
        onPressed: onTap,
        scaleDown: 0.98,
        child: card,
      );
    }

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
