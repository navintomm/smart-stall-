import 'package:flutter/material.dart';
import '../../../core/helpers/animation_durations.dart';

class SlideUpAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;

  const SlideUpAnimation({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.offset = 50.0,
  });

  @override
  State<SlideUpAnimation> createState() => _SlideUpAnimationState();
}

class _SlideUpAnimationState extends State<SlideUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.offset / 100.0), // Relative to child size
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationDurations.defaultCurve,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationDurations.defaultCurve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
