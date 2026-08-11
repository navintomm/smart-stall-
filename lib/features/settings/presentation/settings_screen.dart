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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: ListView(
                  children: [
                    _SettingsGroup(
                      title: 'ARM CONTROL',
                      children: [
                        _SettingsTile(
                          icon: AppIcons.training,
                          iconColor: const Color(0xFF6C63FF),
                          title: 'Robotic Arm Teaching',
                          subtitle: 'Record and teach cleaning routines',
                          onTap: () => context.push(AppRoutes.teaching),
                        ),
                        const Divider(height: 1, indent: 64, color: AppColors.borderLight),
                        _SettingsTile(
                          icon: AppIcons.robot,
                          iconColor: AppColors.dangerRed,
                          title: 'Manual Control',
                          subtitle: 'Direct control without recording',
                          badge: 'MAINTENANCE',
                          badgeColor: AppColors.dangerRed,
                          onTap: () => context.push(AppRoutes.manualControl),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    _SettingsGroup(
                      title: 'ROUTINES',
                      children: [
                        _SettingsTile(
                          icon: AppIcons.library,
                          iconColor: AppColors.informationCyan,
                          title: 'Motion Library',
                          subtitle: 'Manage all saved cleaning routines',
                          onTap: () => context.push(AppRoutes.motionLibrary),
                        ),
                        const Divider(height: 1, indent: 64, color: AppColors.borderLight),
                        _SettingsTile(
                          icon: AppIcons.defaultRoutine,
                          iconColor: AppColors.warningOrange,
                          title: 'Default Routine',
                          subtitle: 'Choose routine used by Start Cleaning',
                          onTap: () => context.push(AppRoutes.defaultRoutine),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
              
              const SizedBox(width: AppSpacing.xxl),
              
              // Right Column
              Expanded(
                child: ListView(
                  children: [
                    _SettingsGroup(
                      title: 'VISION',
                      children: [
                        _SettingsTile(
                          icon: Icons.camera_alt_outlined,
                          iconColor: AppColors.primary,
                          title: 'ArUco Camera Calibration',
                          subtitle: 'Calibrate camera and marker distance',
                          onTap: () => context.push(AppRoutes.cameraCalibration),
                        ),
                        const Divider(height: 1, indent: 64, color: AppColors.borderLight),
                        Consumer(builder: (context, ref, child) {
                          final globalSettings = ref.watch(globalSettingsProvider);
                          return _SettingsTile(
                            icon: Icons.straighten_rounded,
                            iconColor: AppColors.informationCyan,
                            title: 'Global Marker Size',
                            subtitle: '${(globalSettings.defaultMarkerSizeMeters * 1000).toStringAsFixed(0)} mm',
                            onTap: () => _showMarkerSizeDialog(context, ref),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    _DeveloperModeFooter(isUnlocked: devMode),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600)),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor!.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: badgeColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
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
