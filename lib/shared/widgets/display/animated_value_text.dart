import 'package:flutter/material.dart';

class AnimatedValueText extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String suffix;
  final Duration duration;

  const AnimatedValueText({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Text(
          '${val.toStringAsFixed(0)}$suffix',
          style: style,
        );
      },
    );
  }
}
