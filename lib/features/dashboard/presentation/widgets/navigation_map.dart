import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/sensor_data.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';

class NavigationMap extends ConsumerWidget {
  const NavigationMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryRepo = ref.watch(telemetryRepositoryProvider);

    return StreamBuilder<List<SensorData>>(
      stream: telemetryRepo.sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        
        int targetWaypoint = int.tryParse(data.firstWhere((s) => s.id == 'target_waypoint', orElse: () => const SensorData(id: 'target_waypoint', name: '', value: '-1')).value) ?? -1;
        int currentWaypoint = int.tryParse(data.firstWhere((s) => s.id == 'current_waypoint', orElse: () => const SensorData(id: 'current_waypoint', name: '', value: '-1')).value) ?? -1;
        double progress = (int.tryParse(data.firstWhere((s) => s.id == 'navigation_progress', orElse: () => const SensorData(id: 'navigation_progress', name: '', value: '0')).value) ?? 0) / 100.0;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Navigation Map', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: _MapPainter(
                    targetWaypoint: targetWaypoint,
                    currentWaypoint: currentWaypoint,
                    progress: progress,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapPainter extends CustomPainter {
  final int targetWaypoint;
  final int currentWaypoint;
  final double progress;

  _MapPainter({
    required this.targetWaypoint,
    required this.currentWaypoint,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Map<int, Offset> waypoints = {
      100: Offset(size.width * 0.1, size.height * 0.8), // Dock
      101: Offset(size.width * 0.3, size.height * 0.3), // Zone A
      102: Offset(size.width * 0.6, size.height * 0.3), // Zone B
      103: Offset(size.width * 0.9, size.height * 0.8), // Zone C
    };

    final paintLine = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintActiveLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw path
    final path = Path();
    path.moveTo(waypoints[100]!.dx, waypoints[100]!.dy);
    path.lineTo(waypoints[101]!.dx, waypoints[101]!.dy);
    path.lineTo(waypoints[102]!.dx, waypoints[102]!.dy);
    path.lineTo(waypoints[103]!.dx, waypoints[103]!.dy);
    
    canvas.drawPath(path, paintLine);

    // Draw active segment if any
    if (currentWaypoint != -1 && targetWaypoint != -1 && waypoints.containsKey(currentWaypoint) && waypoints.containsKey(targetWaypoint)) {
      final start = waypoints[currentWaypoint]!;
      final end = waypoints[targetWaypoint]!;
      
      final currentPos = Offset(
        start.dx + (end.dx - start.dx) * progress,
        start.dy + (end.dy - start.dy) * progress,
      );

      final activePath = Path();
      activePath.moveTo(start.dx, start.dy);
      activePath.lineTo(currentPos.dx, currentPos.dy);
      canvas.drawPath(activePath, paintActiveLine);

      // Draw Robot
      final paintRobot = Paint()..color = AppColors.secondary;
      canvas.drawCircle(currentPos, 8, paintRobot);
    }

    // Draw nodes
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    waypoints.forEach((id, offset) {
      bool isTarget = id == targetWaypoint;
      bool isCurrent = id == currentWaypoint;
      
      final paintNode = Paint()
        ..color = isTarget ? AppColors.warningOrange : (isCurrent ? AppColors.successGreen : AppColors.textMuted)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(offset, 12, paintNode);
      canvas.drawCircle(offset, 12, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

      textPainter.text = TextSpan(
        text: _getName(id),
        style: TextStyle(color: Colors.white, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy + 16));
    });
  }

  String _getName(int id) {
    switch (id) {
      case 100: return 'Dock';
      case 101: return 'A';
      case 102: return 'B';
      case 103: return 'C';
      default: return '?';
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.targetWaypoint != targetWaypoint || 
           oldDelegate.currentWaypoint != currentWaypoint || 
           oldDelegate.progress != progress;
  }
}
