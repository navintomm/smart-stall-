import 'package:flutter/material.dart';

/// Purpose: A glowing dot to indicate status.
/// Usage: Next to connection states.
/// Parameters:
///   - [color]: Color of the indicator.
/// Example:
/// `dart
/// StatusIndicator(color: AppColors.successGreen);
/// `
class StatusIndicator extends StatefulWidget {
  final Color color;

  const StatusIndicator({super.key, required this.color});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status indicator',
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5 * _animation.value),
                  blurRadius: 8 * _animation.value,
                  spreadRadius: 2 * _animation.value,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
