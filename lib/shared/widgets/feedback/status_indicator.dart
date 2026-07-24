import 'package:flutter/material.dart';

/// Purpose: A glowing dot to indicate status.
/// Usage: Next to connection states.
/// Parameters:
///   - [color]: Color of the indicator.
/// Example:
/// `dart
/// StatusIndicator(color: AppColors.successGreen);
/// `
class StatusIndicator extends StatelessWidget {
  final Color color;

  const StatusIndicator({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status indicator',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
      ),
    );
  }
}
