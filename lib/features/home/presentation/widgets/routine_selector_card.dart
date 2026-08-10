import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../settings/presentation/providers/motion_library_provider.dart';

/// Card displayed at the bottom of the Home screen.
/// Shows the selected routine and the Start button.
class RoutineSelectorCard extends ConsumerStatefulWidget {
  final bool isReady;
  final VoidCallback? onStart;

  const RoutineSelectorCard({
    super.key,
    required this.isReady,
    this.onStart,
  });

  @override
  ConsumerState<RoutineSelectorCard> createState() => _RoutineSelectorCardState();
}

class _RoutineSelectorCardState extends ConsumerState<RoutineSelectorCard> {
  String? _selectedRoutineId;

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(motionLibraryProvider);
    final routines = libraryState.routines;

    // Ensure selection stays valid
    if (_selectedRoutineId == null && libraryState.defaultRoutineId != null) {
      _selectedRoutineId = libraryState.defaultRoutineId;
    }
    if (_selectedRoutineId != null &&
        routines.every((r) => r.id != _selectedRoutineId)) {
      _selectedRoutineId = routines.isEmpty ? null : routines.first.id;
    }

    final canStart = widget.isReady && _selectedRoutineId != null;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section label
          Row(
            children: [
              const Icon(AppIcons.library, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Selected Routine', style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Dropdown
          if (routines.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'No routines saved. Go to Settings → Motion Library.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRoutineId,
                  isExpanded: true,
                  style: AppTextStyles.bodyLarge,
                  icon: const Icon(Icons.expand_more_rounded,
                      color: AppColors.primary),
                  onChanged: (id) => setState(() => _selectedRoutineId = id),
                  items: routines
                      .map((r) => DropdownMenuItem(
                            value: r.id,
                            child: Row(
                              children: [
                                if (r.id == libraryState.defaultRoutineId)
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(right: AppSpacing.sm),
                                    child: Icon(AppIcons.defaultRoutine,
                                        size: 14, color: AppColors.primary),
                                  ),
                                Expanded(
                                  child: Text(r.name,
                                      style: AppTextStyles.bodyLarge,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(r.formattedDuration,
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Start Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: canStart ? AppShadows.glowingGreen : [],
            ),
            child: ElevatedButton.icon(
              onPressed: canStart ? widget.onStart : null,
              icon: Icon(AppIcons.play,
                  size: 22, color: canStart ? Colors.black : Colors.black38),
              label: Text(
                'Start Cleaning',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: canStart ? Colors.black : Colors.black38,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canStart ? AppColors.primary : AppColors.borderLight,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
