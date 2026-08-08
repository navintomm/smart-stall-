import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/developer_mode_provider.dart';
import '../../../shared/widgets/foundation/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(developerModeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/smartstall_logo.png',
                      width: 48,
                      height: 48,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Settings', style: AppTextStyles.displayMedium),
                    Text(
                      'Operator configuration',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            // ── Section Cards ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SettingsSectionCard(
                    icon: AppIcons.training,
                    iconColor: const Color(0xFF6C63FF),
                    title: 'Robotic Arm Teaching',
                    subtitle: 'Record and teach cleaning routines',
                    onTap: () => context.push(AppRoutes.teaching),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsSectionCard(
                    icon: AppIcons.library,
                    iconColor: AppColors.informationCyan,
                    title: 'Motion Library',
                    subtitle: 'Manage all saved cleaning routines',
                    onTap: () => context.push(AppRoutes.motionLibrary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsSectionCard(
                    icon: AppIcons.defaultRoutine,
                    iconColor: AppColors.warningOrange,
                    title: 'Default Routine',
                    subtitle: 'Set which routine loads on Home screen',
                    onTap: () => context.push(AppRoutes.defaultRoutine),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsSectionCard(
                    icon: AppIcons.robot,
                    iconColor: AppColors.dangerRed,
                    title: 'Manual Control',
                    subtitle: 'Maintenance & testing mode',
                    badge: 'MAINTENANCE',
                    badgeColor: AppColors.dangerRed,
                    onTap: () => context.push(AppRoutes.manualControl),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsSectionCard(
                    icon: Icons.camera_alt_outlined,
                    iconColor: AppColors.informationCyan,
                    title: 'Camera Calibration',
                    subtitle: 'Calibrate operator camera for ArUco',
                    onTap: () => context.push(AppRoutes.cameraCalibration),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ]),
              ),
            ),

            // ── Developer Mode Footer ─────────────────────────────────────
            SliverToBoxAdapter(
              child: _DeveloperModeFooter(isUnlocked: devMode),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────
class _SettingsSectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  const _SettingsSectionCard({
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
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: AppSpacing.lg),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor!.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: badgeColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Developer Mode Footer ────────────────────────────────────────────────────
class _DeveloperModeFooter extends ConsumerStatefulWidget {
  final bool isUnlocked;
  const _DeveloperModeFooter({required this.isUnlocked});

  @override
  ConsumerState<_DeveloperModeFooter> createState() =>
      _DeveloperModeFooterState();
}

class _DeveloperModeFooterState extends ConsumerState<_DeveloperModeFooter> {
  void _onVersionTap() {
    final unlocked =
        ref.read(developerModeProvider.notifier).onVersionTap();
    if (unlocked && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(AppIcons.unlock, color: Colors.white, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text('Developer Mode Unlocked',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white)),
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
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.massive),
      child: Column(
        children: [
          GestureDetector(
            onTap: _onVersionTap,
            child: Text(
              'SmartStall Operator v1.0.0',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.isUnlocked) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.developerCenter),
              icon: const Icon(AppIcons.developer,
                  size: 16, color: AppColors.informationCyan),
              label: Text(
                'Open Developer Center',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.informationCyan,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
