import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'widgets/system_overview_card.dart';
import 'widgets/telemetry_monitor_card.dart';
import 'widgets/communication_log_card.dart';
import 'widgets/developer_settings_card.dart';
import 'widgets/performance_panel_card.dart';
import 'pages/protocol_playground_page.dart';

class DeveloperDashboardScreen extends ConsumerWidget {
  const DeveloperDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Developer & Diagnostics Center'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Protocol Playground',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProtocolPlaygroundPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warningOrange.withOpacity(0.15),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.15),
                ),
              ),
            ),
          ),
          
          const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SystemOverviewCard(),
                  SizedBox(height: AppSpacing.xl),
                  PerformancePanelCard(),
                  SizedBox(height: AppSpacing.xl),
                  DeveloperSettingsCard(),
                  SizedBox(height: AppSpacing.xl),
                  TelemetryMonitorCard(),
                  SizedBox(height: AppSpacing.xl),
                  CommunicationLogCard(),
                  SizedBox(height: AppSpacing.colossal),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

