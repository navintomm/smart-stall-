import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

class AppDivider extends StatelessWidget {
  final double height;
  final double indent;
  final double endIndent;

  const AppDivider({
    super.key,
    this.height = AppSpacing.lg,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Divider(
      height: height,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }
}
