import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../vision/domain/services/auto_alignment_service.dart';

/// Animated status banner + Auto-Align toggle that watches the real
/// [AutoAlignmentNotifier] state machine.
class AlignmentStatusBanner extends ConsumerWidget {
  final double alignmentScore;
  final bool hasMarker;

  const AlignmentStatusBanner({
    super.key,
    required this.alignmentScore,
    required this.hasMarker,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoState = ref.watch(autoAlignmentServiceProvider);
    final isAutoActive = autoState.status == AutoAlignState.aligning;
    final isAligned = autoState.status == AutoAlignState.aligned;
    final isVisuallyReady =
        isAligned || (hasMarker && alignmentScore >= 0.95);

    // Determine banner content based on auto-alignment state
    String bannerLabel;
    Color bannerColor;
    IconData bannerIcon;
    bool animate;

    if (isAligned) {
      bannerLabel = 'Aligned ✓';
      bannerColor = AppColors.successGreen;
      bannerIcon = Icons.check_circle_rounded;
      animate = false;
    } else if (isVisuallyReady) {
      bannerLabel = 'Ready to Start';
      bannerColor = AppColors.successGreen;
      bannerIcon = Icons.check_circle_rounded;
      animate = false;
    } else if (autoState.status == AutoAlignState.markerLost) {
      bannerLabel = 'Marker Lost — Stopped';
      bannerColor = AppColors.dangerRed;
      bannerIcon = Icons.error_outline_rounded;
      animate = true;
    } else if (autoState.status == AutoAlignState.error) {
      // Distinguish the specific error reason from the auto-alignment state machine
      if (autoState.lastCommand.contains('E-Stop')) {
        bannerLabel = 'E-Stop Engaged — Stopped';
        bannerColor = AppColors.dangerRed;
        bannerIcon = Icons.emergency_rounded;
      } else if (autoState.lastCommand.contains('Disconnected')) {
        bannerLabel = 'Connection Lost — Stopped';
        bannerColor = AppColors.dangerRed;
        bannerIcon = Icons.link_off_rounded;
      } else if (autoState.lastCommand.contains('Uncalibrated')) {
        bannerLabel = 'Camera Not Calibrated';
        bannerColor = AppColors.warningOrange;
        bannerIcon = Icons.straighten_rounded;
      } else {
        bannerLabel = 'Vision Timeout';
        bannerColor = AppColors.dangerRed;
        bannerIcon = Icons.warning_amber_rounded;
      }
      animate = true;
    } else if (isAutoActive) {
      bannerLabel = 'Auto-Aligning…';
      bannerColor = AppColors.primary;
      bannerIcon = Icons.auto_mode;
      animate = true;
    } else if (hasMarker) {
      bannerLabel = 'Aligning…';
      bannerColor = AppColors.warningOrange;
      bannerIcon = Icons.adjust_rounded;
      animate = true;
    } else {
      bannerLabel = 'Scanning for Marker…';
      bannerColor = AppColors.warningOrange;
      bannerIcon = Icons.adjust_rounded;
      animate = true;
    }

    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: _BannerPill(
              key: ValueKey(bannerLabel),
              icon: bannerIcon,
              label: bannerLabel,
              backgroundColor: bannerColor.withOpacity(0.12),
              borderColor: bannerColor,
              textColor: bannerColor,
              iconColor: bannerColor,
              animate: animate,
            ),
          ),
        ),
        if (hasMarker && !isVisuallyReady) ...[
          const SizedBox(width: AppSpacing.sm),
          _AutoAlignButton(
            isActive: isAutoActive,
            onPressed: () {
              final notifier =
                  ref.read(autoAlignmentServiceProvider.notifier);
              if (isAutoActive) {
                notifier.stopAutoAlignment();
              } else {
                notifier.startAutoAlignment();
              }
            },
          ),
        ],
      ],
    );
  }
}

// ─── Auto-Align Button ───────────────────────────────────────────────────────

class _AutoAlignButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;
  const _AutoAlignButton(
      {required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        isActive ? Icons.stop_rounded : Icons.auto_mode,
        size: 18,
        color: isActive ? AppColors.dangerRed : AppColors.primary,
      ),
      label: Text(
        isActive ? 'Stop' : 'Auto-Align',
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.dangerRed : AppColors.primary,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: (isActive ? AppColors.dangerRed : AppColors.primary)
            .withOpacity(0.1),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      ),
    );
  }
}

// ─── Banner Pill ─────────────────────────────────────────────────────────────

class _BannerPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final bool animate;

  const _BannerPill({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    this.animate = false,
  });

  @override
  State<_BannerPill> createState() => _BannerPillState();
}

class _BannerPillState extends State<_BannerPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: widget.borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: widget.iconColor, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                widget.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: widget.textColor,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
