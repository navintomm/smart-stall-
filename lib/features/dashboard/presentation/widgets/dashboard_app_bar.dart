import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/feedback/status_chip.dart';
import '../../../../shared/widgets/foundation/glass_icon_button.dart';

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SmartStall Operator', style: AppTextStyles.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text("$dateStr • $timeStr", style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
            ],
          ),
          Row(
            children: [
              const StatusChip(label: 'Connected', color: AppColors.successGreen),
              const SizedBox(width: AppSpacing.sm),
              GlassIconButton(
                icon: const Icon(AppIcons.settings, color: AppColors.primary),
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

