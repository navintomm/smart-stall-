import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/empty_state_view.dart';

class CommunicationLogCard extends ConsumerWidget {
  const CommunicationLogCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      animateEntrance: true,
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Communication Log', style: AppTextStyles.titleLarge),
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.primary),
                tooltip: 'Export Logs',
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const EmptyStateView(
              icon: Icons.sync,
              title: 'No Communications Yet',
              message: 'The hardware log is currently empty. Connect a robot to begin streaming telemetry.',
            ),
          ),
        ],
      ),
    );
  }

}
