import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

/// Purpose: A list tile styled for glassmorphism.
/// Usage: Displaying rows of information.
/// Parameters:
///   - [title]: Tile title.
///   - [subtitle]: Tile subtitle.
/// Example:
/// `dart
/// InfoTile(title: 'Status', subtitle: 'Connected');
/// `
class InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const InfoTile({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: AppColors.cardGlass.withOpacity(0.5),
        borderRadius: AppRadius.smallRadius,
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
