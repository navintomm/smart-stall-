import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'widgets/system_overview_card.dart';
import 'widgets/telemetry_monitor_card.dart';
import 'widgets/communication_log_card.dart';
import 'widgets/developer_settings_card.dart';
import 'widgets/performance_panel_card.dart';
import 'widgets/cleaning_diagnostics_card.dart';
import 'widgets/vision_diagnostics_card.dart';
import 'widgets/navigation_diagnostics_card.dart';
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
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SystemOverviewCard(),
              SizedBox(height: AppSpacing.xl),
              PerformancePanelCard(),
              SizedBox(height: AppSpacing.xl),
              NavigationDiagnosticsCard(),
              SizedBox(height: AppSpacing.xl),
              VisionDiagnosticsCard(),
              SizedBox(height: AppSpacing.xl),
              CleaningDiagnosticsCard(),
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
    );
  }
}

