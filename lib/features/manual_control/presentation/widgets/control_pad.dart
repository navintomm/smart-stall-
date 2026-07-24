import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class ControlPad extends StatelessWidget {
  const ControlPad({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DirectionButton(icon: Icons.keyboard_arrow_up, label: 'Forward'),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DirectionButton(icon: Icons.keyboard_arrow_left, label: 'Left'),
                SizedBox(width: AppSpacing.sm),
                _DirectionButton(icon: Icons.stop_circle, label: 'Stop', color: AppColors.dangerRed),
                SizedBox(width: AppSpacing.sm),
                _DirectionButton(icon: Icons.keyboard_arrow_right, label: 'Right'),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            _DirectionButton(icon: Icons.keyboard_arrow_down, label: 'Backward'),
          ],
        ),
      ),
    );
  }
}

class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _DirectionButton({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: effectiveColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: effectiveColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: effectiveColor, size: 32),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: effectiveColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
