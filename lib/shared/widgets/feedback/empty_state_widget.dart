import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Purpose: Shows when no data is available.
/// Usage: Empty lists or missing features.
/// Parameters:
///   - [message]: The empty state message.
///   - [icon]: The icon to display.
/// Example:
/// `dart
/// EmptyStateWidget(message: 'No items', icon: Icons.inbox);
/// `
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.text.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: AppColors.text.withOpacity(0.5), fontSize: 16)),
        ],
      ),
    );
  }
}
