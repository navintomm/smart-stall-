import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/foundation/glass_card.dart';
import '../../../../core/communication/protocol/models/base_packet.dart';
import '../../../../core/communication/protocol/models/packet_type.dart';
import '../../../../core/communication/protocol/catalogues/command_catalog.dart';
import '../../../../core/communication/protocol/validator/protocol_validator.dart';
import '../../../../core/communication/protocol/protocol_codec.dart';

class ProtocolPlaygroundPage extends ConsumerStatefulWidget {
  const ProtocolPlaygroundPage({super.key});

  @override
  ConsumerState<ProtocolPlaygroundPage> createState() => _ProtocolPlaygroundPageState();
}

class _ProtocolPlaygroundPageState extends ConsumerState<ProtocolPlaygroundPage> {
  final _jsonController = TextEditingController();
  String _validationResult = '';
  Color _validationColor = Colors.grey;
  CommandDefinition _selectedCommand = CommandCatalog.moveForward;
  final ProtocolCodec _codec = ProtocolCodec();

  @override
  void initState() {
    super.initState();
    _generateMockCommand();
  }

  void _generateMockCommand() {
    final payload = <String, dynamic>{};
    for (var key in _selectedCommand.requiredPayloadKeys) {
      payload[key] = 0; // Default placeholder
    }

    final cmd = RobotPacket(
      type: PacketType.command,
      commandId: _selectedCommand.id,
      sequenceNumber: 1,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      payload: payload,
      crc: ProtocolValidator.calculateChecksum(payload),
    );
    _jsonController.text = _codec.prettyPrint(cmd);
  }

  void _validatePacket() {
    final jsonStr = _jsonController.text;
    
    if (!ProtocolValidator.validateLength(jsonStr)) {
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
          _validationResult = 'ERROR: Missing required fields (ver, type, seq, ts, data, crc).';
          _validationColor = AppColors.dangerRed;
        });
        return;
      }

      final packet = RobotPacket.fromJson(map);
      
      if (!ProtocolValidator.validateChecksum(map, packet.crc)) {
        setState(() {
          _validationResult = 'ERROR: CRC Checksum mismatch.';
          _validationColor = AppColors.dangerRed;
        });
        return;
      }

      if (packet.type == PacketType.command) {
        final payloadError = ProtocolValidator.validateCommandPayload(packet);
        if (payloadError != null) {
          setState(() {
            _validationResult = 'ERROR: $payloadError';
            _validationColor = AppColors.warningOrange;
          });
          return;
        }
      }
      
      setState(() {
        _validationResult = 'SUCCESS: Packet is perfectly valid and ready for transmission.';
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
            DropdownButton<CommandDefinition>(
              value: _selectedCommand,
              isExpanded: true,
              items: CommandCatalog.allCommands.map((cmd) {
                return DropdownMenuItem(
                  value: cmd,
                  child: Text(cmd.name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCommand = val;
                    _generateMockCommand();
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Packet Editor', style: AppTextStyles.displayMedium),
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
                    child: const Text('Reset to Default'),
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
