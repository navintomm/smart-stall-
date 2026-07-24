import 'package:flutter/material.dart';
import '../display/circular_progress_glass.dart';

/// Purpose: Full screen loading blocker.
/// Usage: Wrap around screens that are loading data.
/// Parameters:
///   - [isLoading]: Whether to show the overlay.
///   - [child]: The screen content.
/// Example:
/// `dart
/// LoadingOverlay(isLoading: true, child: Screen());
/// `
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressGlass()),
          ),
      ],
    );
  }
}

