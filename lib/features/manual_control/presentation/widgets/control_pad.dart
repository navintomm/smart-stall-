import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_shadows.dart';
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
    final effectiveColor = color ?? AppColors.text;
    final isDanger = color == AppColors.dangerRed;
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardGlass,
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 86,
            height: 86,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: effectiveColor, size: 36),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(color: effectiveColor, fontSize: 11, fontWeight: isDanger ? FontWeight.bold : FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
