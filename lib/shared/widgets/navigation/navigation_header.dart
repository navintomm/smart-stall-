import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../foundation/glass_icon_button.dart';

/// Purpose: A standardized back-navigation header for sub-modules.
/// Usage: Top of all module screens.
class NavigationHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const NavigationHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GlassIconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: AppTextStyles.displayLarge.copyWith(fontSize: 24)),
        ],
      ),
    );
  }
}

