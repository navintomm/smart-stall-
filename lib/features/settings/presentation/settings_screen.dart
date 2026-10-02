import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/developer_mode_provider.dart';
import 'providers/global_settings_provider.dart';
import '../../connection/presentation/providers/bluetooth_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(developerModeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Operator Settings',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Row 1: ARM CONTROL + ROUTINES + VISION ──────────────────
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ARM CONTROL
                    Expanded(
                      child: _SettingsGroup(
                        title: 'ARM CONTROL',
                        children: [
                          _SettingsTile(
                            icon: AppIcons.training,
                            iconColor: const Color(0xFF6C63FF),
                            title: 'Teaching',
                            subtitle: 'Record cleaning routines',
                            onTap: () => _showTeachingSelectionDialog(context),
                          ),
                          const Divider(height: 1, indent: 64, color: AppColors.borderLight),
                          _SettingsTile(
                            icon: Icons.bluetooth_rounded,
                            iconColor: Colors.blueAccent,
                            title: 'Bluetooth',
                            subtitle: 'Connect to HC-05',
                            onTap: () => _showBluetoothDialog(context, ref),
                          ),
                          const Divider(height: 1, indent: 64, color: AppColors.borderLight),
                          _SettingsTile(
                            icon: AppIcons.robot,
                            iconColor: AppColors.dangerRed,
                            title: 'Manual Control',
                            subtitle: 'Direct control',
                            badge: 'MAINTENANCE',
                            badgeColor: AppColors.dangerRed,
                            onTap: () => context.push(AppRoutes.manualControl),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // ROUTINES
                    Expanded(
                      child: _SettingsGroup(
                        title: 'ROUTINES',
                        children: [
                          _SettingsTile(
                            icon: AppIcons.library,
                            iconColor: AppColors.informationCyan,
                            title: 'Motion Library',
                            subtitle: 'Manage saved routines',
                            onTap: () => context.push(AppRoutes.motionLibrary),
                          ),
                          const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                          _SettingsTile(
                            icon: AppIcons.defaultRoutine,
                            iconColor: AppColors.warningOrange,
                            title: 'Default Routine',
                            subtitle: 'Used by Start Cleaning',
                            onTap: () => context.push(AppRoutes.defaultRoutine),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // VISION
                    Expanded(
                      child: _SettingsGroup(
                        title: 'VISION',
                        children: [
                          _SettingsTile(
                            icon: Icons.camera_alt_outlined,
                            iconColor: AppColors.primary,
                            title: 'ArUco Calibration',
                            subtitle: 'Calibrate camera & distance',
                            onTap: () => context.push(AppRoutes.cameraCalibration),
                          ),
                          const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                          Consumer(builder: (context, ref, child) {
                            final globalSettings = ref.watch(globalSettingsProvider);
                            return _SettingsTile(
                              icon: Icons.straighten_rounded,
                              iconColor: AppColors.informationCyan,
                              title: 'Marker Size',
                              subtitle: '${(globalSettings.defaultMarkerSizeMeters * 1000).toStringAsFixed(0)} mm',
                              onTap: () => _showMarkerSizeDialog(context, ref),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Footer: Version + Dev Mode ───────────────────────────────
              _DeveloperModeFooter(isUnlocked: devMode),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeachingSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Teaching Mode'),
        content: const Text('How would you like to record a new cleaning routine?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.manualTeaching);
            },
            child: const Text('Manual Teaching'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.teaching);
            },
            child: const Text('Joystick Teaching'),
          ),
        ],
      ),
    );
  }

  void _showMarkerSizeDialog(BuildContext context, WidgetRef ref) {
    final currentSize = ref.read(globalSettingsProvider).defaultMarkerSizeMeters * 1000.0;
    final controller = TextEditingController(text: currentSize.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Global Marker Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the physical size (width) of the ArUco marker in millimetres.'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                suffixText: 'mm',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                ref.read(globalSettingsProvider.notifier).setDefaultMarkerSize(val / 1000.0);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showBluetoothDialog(BuildContext context, WidgetRef ref) async {
    // Request runtime Bluetooth permissions (required on Android 12+)
    final statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    final connectGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    final scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;

    if (!connectGranted || !scanGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth permissions denied. Please grant them in Settings.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Start BLE scan instead of loading bonded devices
    ref.read(bluetoothProvider.notifier).startScan();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, child) {
          final bluetoothState = ref.watch(bluetoothProvider);
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Connect to ESP32 BLE'),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(bluetoothProvider.notifier).startScan(),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: bluetoothState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (results) {
                  if (results.isEmpty) {
                    return const Center(
                      child: Text('Scanning for BLE devices...\nMake sure your ESP32 is powered on.', textAlign: TextAlign.center),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final r = results[index];
                      final name = r.device.advName.isNotEmpty ? r.device.advName : 'Unknown Device';
                      return ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(name),
                        subtitle: Text('${r.device.remoteId.str} (RSSI: ${r.rssi})'),
                        onTap: () async {
                          ref.read(bluetoothProvider.notifier).stopScan();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connecting to $name...')));
                          
                          final success = await ref.read(bluetoothProvider.notifier).connect(r.device.remoteId.str);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connected to $name successfully!'), backgroundColor: Colors.green));
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to connect.'), backgroundColor: Colors.red));
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(bluetoothProvider.notifier).stopScan();
                  Navigator.pop(context);
                }, 
                child: const Text('Close'),
              ),
            ],
          );
        });
      },
    ).then((_) {
      // Ensure we stop scanning when dialog is closed via outside tap
      ref.read(bluetoothProvider.notifier).stopScan();
    });
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
          child: Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: badgeColor!.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: badgeColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _DeveloperModeFooter extends ConsumerStatefulWidget {
  final bool isUnlocked;
  const _DeveloperModeFooter({required this.isUnlocked});

  @override
  ConsumerState<_DeveloperModeFooter> createState() => _DeveloperModeFooterState();
}

class _DeveloperModeFooterState extends ConsumerState<_DeveloperModeFooter> {
  void _onVersionTap() {
    final unlocked = ref.read(developerModeProvider.notifier).onVersionTap();
    if (unlocked && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(AppIcons.unlock, color: Colors.white, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text('Developer Mode Unlocked', style: AppTextStyles.bodyLarge.copyWith(color: Colors.white)),
          ]),
          backgroundColor: const Color(0xFF1E1E2E),
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _onVersionTap,
          child: Text(
            'SmartStall Operator v1.0.0',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
        if (widget.isUnlocked) ...[
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.developerCenter),
            icon: const Icon(AppIcons.developer, size: 16, color: AppColors.informationCyan),
            label: Text(
              'Open Developer Center',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.informationCyan),
            ),
          ),
        ],
      ],
    );
  }
}
