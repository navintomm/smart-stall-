import 'package:flutter/material.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.backgroundColor,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = backgroundColor ?? theme.colorScheme.surface;

    Widget card = Material(
      color: cardColor,
      elevation: elevation,
      shadowColor: Colors.black.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: card,
      );
    }
    
    return card;
  }
}
