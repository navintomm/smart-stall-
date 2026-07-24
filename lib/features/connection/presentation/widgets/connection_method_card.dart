import 'package:flutter/material.dart';
import '../../domain/models/connection_method.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/status_chip.dart';

class ConnectionMethodCard extends StatelessWidget {
  final ConnectionMethod method;

  const ConnectionMethodCard({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    final isConnected = method.status == 'Connected';
    
    return GlassCard(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isConnected ? AppColors.primary.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(method.icon, color: isConnected ? AppColors.primary : Colors.black54, size: 32),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(method.description, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
              StatusChip(
                label: method.status,
                color: isConnected ? AppColors.successGreen : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
