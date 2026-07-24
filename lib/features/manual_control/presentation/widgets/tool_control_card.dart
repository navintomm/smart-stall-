import 'package:flutter/material.dart';
import '../../domain/models/tool_control.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/status_indicator.dart';

class ToolControlCard extends StatelessWidget {
  final ToolControl tool;

  const ToolControlCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(tool.icon, color: tool.isActive ? AppColors.primary : Colors.black54),
                  const SizedBox(width: AppSpacing.sm),
                  Text(tool.name, style: AppTextStyles.bodyLarge),
                ],
              ),
              StatusIndicator(color: tool.isActive ? AppColors.successGreen : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
