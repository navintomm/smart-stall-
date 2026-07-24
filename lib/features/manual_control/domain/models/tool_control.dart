import 'package:flutter/material.dart';
import '../../../../core/theme/app_icons.dart';

class ToolControl {
  final String id;
  final String name;
  final IconData icon;
  final bool isActive;

  const ToolControl({
    required this.id,
    required this.name,
    required this.icon,
    required this.isActive,
  });

  static List<ToolControl> get placeholders => [
    const ToolControl(id: 't1', name: 'Water Pump', icon: AppIcons.water, isActive: false),
    const ToolControl(id: 't2', name: 'Soap Pump', icon: Icons.bubble_chart, isActive: true),
    const ToolControl(id: 't3', name: 'Brush Motor', icon: Icons.settings, isActive: false),
    const ToolControl(id: 't4', name: 'Brush Rotation', icon: Icons.rotate_right, isActive: false),
    const ToolControl(id: 't5', name: 'Vacuum', icon: Icons.air, isActive: false),
  ];
}
