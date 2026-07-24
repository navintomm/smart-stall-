import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/communication/protocol/v1/v1_command.dart';
import '../../../../core/communication/protocol/v1/validator/protocol_validator.dart';

class ProtocolPlaygroundPage extends ConsumerStatefulWidget {
  const ProtocolPlaygroundPage({super.key});

  @override
  ConsumerState<ProtocolPlaygroundPage> createState() => _ProtocolPlaygroundPageState();
}

class _ProtocolPlaygroundPageState extends ConsumerState<ProtocolPlaygroundPage> {
  final _jsonController = TextEditingController();
  String _validationResult = '';
  Color _validationColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _generateMockCommand();
  }

  void _generateMockCommand() {
    final cmd = V1Command(
      commandId: 1001,
      commandType: 'MOVE_SERVO',
      payload: {'id': 'joint_1', 'angle': 45},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _jsonController.text = const JsonEncoder.withIndent('  ').convert(cmd.toJson());
  }

  void _validatePacket() {
    final jsonStr = _jsonController.text;
    
    if (!ProtocolValidator.validateCommandSize(jsonStr)) {
      setState(() {
        _validationResult = 'ERROR: Payload exceeds size limit!';
        _validationColor = AppColors.dangerRed;
      });
      return;
    }

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (!ProtocolValidator.validateRequiredFields(map)) {
        setState(() {
          _validationResult = 'ERROR: Missing required V1Command fields.';
          _validationColor = AppColors.dangerRed;
        });
        return;
      }
      
      final checksum = ProtocolValidator.calculateChecksum(jsonStr);
      setState(() {
        _validationResult = 'SUCCESS: Packet is valid.\\nChecksum: $checksum';
        _validationColor = AppColors.successGreen;
      });
    } catch (e) {
      setState(() {
        _validationResult = 'ERROR: Invalid JSON syntax.\\n$e';
        _validationColor = AppColors.dangerRed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protocol Playground')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('V1 Command Builder', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _jsonController,
                  maxLines: 12,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter JSON packet...',
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateMockCommand,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      backgroundColor: Colors.black12,
                    ),
                    child: const Text('Generate Mock'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _validatePacket,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Validate Packet', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Validation Results', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: _validationColor.withOpacity(0.1),
                child: Text(
                  _validationResult.isEmpty ? 'Waiting for validation...' : _validationResult,
                  style: TextStyle(color: _validationColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

