import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/widgets/navigation/navigation_header.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../providers/motion_library_provider.dart';
import '../../domain/models/routine.dart';

class MotionLibraryPage extends ConsumerWidget {
  const MotionLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(motionLibraryProvider);
    final routines = libraryState.routines;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const NavigationHeader(
                title: 'Motion Library', icon: AppIcons.library),
            Expanded(
              child: routines.isEmpty
                  ? const EmptyStateWidget(
                      icon: AppIcons.library,
                      message:
                          'No routines saved. Go to Settings → Arm Teaching to record one.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: routines.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (ctx, i) => _RoutineCard(
                        routine: routines[i],
                        isDefault:
                            routines[i].id == libraryState.defaultRoutineId,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Routine Card ─────────────────────────────────────────────────────────────
class _RoutineCard extends ConsumerWidget {
  final Routine routine;
  final bool isDefault;

  const _RoutineCard({required this.routine, required this.isDefault});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(motionLibraryProvider.notifier);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isDefault)
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(AppIcons.defaultRoutine,
                                      size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text('Default',
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            routine.name,
                            style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${routine.frames.length} frames · ${routine.formattedDuration} · ${_formatDate(routine.createdAt)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              // 3-dot menu
              PopupMenuButton<_RoutineAction>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textMuted),
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mediumRadius),
                onSelected: (action) =>
                    _handleAction(context, ref, action, notifier),
                itemBuilder: (_) => [
                  _menuItem(_RoutineAction.preview, AppIcons.preview, 'Preview'),
                  _menuItem(_RoutineAction.rename, AppIcons.rename, 'Rename'),
                  _menuItem(
                      _RoutineAction.duplicate, AppIcons.duplicate, 'Duplicate'),
                  if (!isDefault)
                    _menuItem(_RoutineAction.setDefault, AppIcons.defaultRoutine,
                        'Set as Default'),
                  const PopupMenuDivider(),
                  _menuItem(_RoutineAction.delete, Icons.delete_outline_rounded,
                      'Delete',
                      color: AppColors.dangerRed),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action buttons row
          Row(
            children: [
              _ActionButton(
                icon: AppIcons.preview,
                label: 'Preview',
                onTap: () => _showPreview(context),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (!isDefault)
                _ActionButton(
                  icon: AppIcons.defaultRoutine,
                  label: 'Set Default',
                  onTap: () => notifier.setDefault(routine.id),
                  accent: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_RoutineAction> _menuItem(
      _RoutineAction action, IconData icon, String label,
      {Color? color}) {
    return PopupMenuItem(
      value: action,
      child: Row(children: [
        Icon(icon, size: 18, color: color ?? AppColors.text),
        const SizedBox(width: AppSpacing.md),
        Text(label,
            style: AppTextStyles.bodyLarge.copyWith(color: color)),
      ]),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref,
      _RoutineAction action, MotionLibraryNotifier notifier) {
    switch (action) {
      case _RoutineAction.preview:
        _showPreview(context);
        break;
      case _RoutineAction.rename:
        _showRenameDialog(context, notifier);
        break;
      case _RoutineAction.duplicate:
        notifier.duplicate(routine.id);
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Routine duplicated'),
        );
        break;
      case _RoutineAction.setDefault:
        notifier.setDefault(routine.id);
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Set as default routine'),
        );
        break;
      case _RoutineAction.delete:
        _showDeleteConfirm(context, notifier);
        break;
    }
  }

  void _showPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PreviewSheet(routine: routine),
    );
  }

  void _showRenameDialog(BuildContext context, MotionLibraryNotifier notifier) {
    final ctrl = TextEditingController(text: routine.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        title: const Text('Rename Routine'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: AppRadius.mediumRadius),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mediumRadius,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              notifier.rename(routine.id, ctrl.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, MotionLibraryNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        title: const Text('Delete Routine?'),
        content: Text('This will permanently delete "${routine.name}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              notifier.delete(routine.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  SnackBar _snackBar(String message) => SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
      );

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}

enum _RoutineAction { preview, rename, duplicate, setDefault, delete }

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon,
          size: 15, color: accent ? AppColors.primary : AppColors.textSecondary),
      label: Text(label,
          style: AppTextStyles.bodySmall.copyWith(
              color: accent ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
            color: accent
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.borderLight),
        shape: const StadiumBorder(),
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
      ),
    );
  }
}

// ─── Preview Bottom Sheet ─────────────────────────────────────────────────────
class _PreviewSheet extends StatelessWidget {
  final Routine routine;
  const _PreviewSheet({required this.routine});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(routine.name, style: AppTextStyles.displayMedium),
          const SizedBox(height: 4),
          Text(
            '${routine.frames.length} frames · ${routine.formattedDuration} · ${routine.frames.isNotEmpty ? "100ms interval" : "empty"}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Frame timeline visualiser (simple bar chart)
          Expanded(
            child: routine.frames.isEmpty
                ? const Center(child: Text('No frames recorded'))
                : _FrameTimeline(values: routine.frames
                    .map((f) => f.servoAngles.isEmpty ? 0.0 : f.servoAngles.values
                        .fold(0.0, (a, b) => a + b) /
                        f.servoAngles.length)
                    .toList()),
          ),
        ],
      ),
    );
  }
}

class _FrameTimeline extends StatelessWidget {
  final List<double> values; // average servo angle per frame
  const _FrameTimeline({required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final max = values.fold(0.0, (a, b) => a > b ? a : b);
    return LayoutBuilder(builder: (_, c) {
      final barW = (c.maxWidth / values.length).clamp(1.0, 8.0);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final h = max > 0 ? (v / max) * (c.maxHeight * 0.8) : 4.0;
          return Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Container(
              width: barW,
              height: h.clamp(2.0, double.infinity),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
