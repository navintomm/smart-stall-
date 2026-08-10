import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../providers/motion_library_provider.dart';

class DefaultRoutinePage extends ConsumerWidget {
  const DefaultRoutinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(motionLibraryProvider);
    final routines = libraryState.routines;
    final defaultId = libraryState.defaultRoutineId;
    final notifier = ref.read(motionLibraryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Default Routine',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
              child: Text(
                'The selected routine will appear pre-loaded on the Home screen, ready to start.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),

            Expanded(
              child: routines.isEmpty
                  ? const EmptyStateWidget(
                      icon: AppIcons.library,
                      message:
                          'No routines available. Record one in Arm Teaching.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      itemCount: routines.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, i) {
                        final r = routines[i];
                        final isSelected = r.id == defaultId;
                        return GlassCard(
                          padding: EdgeInsets.zero,
                          onTap: () => notifier.setDefault(r.id),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Row(
                              children: [
                                // Radio
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.borderLight,
                                      width: isSelected ? 6 : 2,
                                    ),
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.name,
                                        style: AppTextStyles.titleLarge
                                            .copyWith(
                                          fontSize: 16,
                                          color: isSelected
                                              ? AppColors.text
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${r.frames.length} frames · ${r.formattedDuration}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(AppIcons.success,
                                      color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
