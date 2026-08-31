import 'package:flutter/material.dart';
import '../../../../features/vision/domain/models/dirt_severity.dart';
import '../../../../features/vision/domain/models/dirt_detection_result.dart';
import '../../domain/models/cleaning_profile.dart';

class CleaningDecisionSummaryWidget extends StatelessWidget {
  final DirtDetectionResult result;
  final CleaningProfile profile;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CleaningDecisionSummaryWidget({
    super.key,
    required this.result,
    required this.profile,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'AI Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Dirt:', profile.severity.displayName, isHighlight: true),
            const SizedBox(height: 12),
            _buildInfoRow('Confidence:', '${(result.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
            _buildInfoRow('Recommended:', profile.routineId.replaceAll('_', ' ').toUpperCase()),
            const SizedBox(height: 12),
            _buildInfoRow('Water:', '${profile.waterVolumeMl} mL'),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Estimated Duration:', 
              '${(profile.pumpDurationMs + profile.brushDurationMs) ~/ 1000} seconds'
            ),
            if (result.isSimulation)
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  'SIMULATION / DEVELOPMENT',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('CONFIRM & START CLEANING'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? Colors.black87 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
