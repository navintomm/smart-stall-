import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../vision/domain/services/auto_alignment_service.dart';

/// Animated status banner that transitions between "Aligning..." and "Ready to Start".
class AlignmentStatusBanner extends ConsumerWidget {
  final double alignmentScore; // 0.0 – 1.0
  final bool hasMarker;

  const AlignmentStatusBanner({
    super.key,
    required this.alignmentScore,
    required this.hasMarker,
  });

  bool get _isReady => hasMarker && alignmentScore >= 0.95;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _isReady
                ? _BannerPill(
                    key: const ValueKey('ready'),
                    icon: Icons.check_circle_rounded,
                    label: 'Ready to Start',
                    backgroundColor: AppColors.successGreen.withOpacity(0.15),
                    borderColor: AppColors.successGreen,
                    textColor: AppColors.successGreen,
                    iconColor: AppColors.successGreen,
                  )
                : _BannerPill(
                    key: const ValueKey('aligning'),
                    icon: Icons.adjust_rounded,
                    label: hasMarker ? 'Aligning...' : 'Scanning for Marker...',
                    backgroundColor: AppColors.warningOrange.withOpacity(0.12),
                    borderColor: AppColors.warningOrange,
                    textColor: AppColors.warningOrange,
                    iconColor: AppColors.warningOrange,
                    animate: true,
                  ),
          ),
        ),
        if (!_isReady && hasMarker) ...[
          const SizedBox(width: AppSpacing.md),
          TextButton.icon(
            onPressed: () {
              ref.read(autoAlignmentServiceProvider).startAutoAlignment();
            },
            icon: const Icon(Icons.auto_mode, size: 20),
            label: const Text('Auto-Align'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            ),
          ),
        ],
      ],
    );
  }
}

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
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: widget.borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: widget.iconColor, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: widget.textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
