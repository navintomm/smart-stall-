import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SignalStrengthIndicator extends StatelessWidget {
  final int quality; // 0 to 100

  const SignalStrengthIndicator({super.key, required this.quality});

  @override
  Widget build(BuildContext context) {
    int bars = (quality / 25).ceil();
    if (bars > 4) bars = 4;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final isActive = index < bars;
        return Container(
          margin: const EdgeInsets.only(right: 2),
          width: 4,
          height: 8.0 + (index * 4.0),
          decoration: BoxDecoration(
            color: isActive ? AppColors.successGreen : Colors.black12,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
