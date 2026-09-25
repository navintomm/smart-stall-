import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../providers/manual_teaching_provider.dart';
import '../../domain/models/trajectory_recording_state.dart';
import '../../../../core/providers/app_config_provider.dart';

class ManualTeachingPage extends ConsumerStatefulWidget {
  const ManualTeachingPage({super.key});

  @override
  ConsumerState<ManualTeachingPage> createState() => _ManualTeachingPageState();
}

class _ManualTeachingPageState extends ConsumerState<ManualTeachingPage> {
  
  void _showSaveDialog(BuildContext context) {
    final nameController = TextEditingController();
    final markerIdController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        title: const Row(
          children: [
            Icon(AppIcons.library, color: AppColors.primary, size: 22),
            SizedBox(width: AppSpacing.sm),
            Text('Save Manual Routine'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Give this routine a name so you can identify it.', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Wipe Motion 1',
                hintStyle: AppTextStyles.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: markerIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Target ArUco Marker ID (Optional)',
                hintStyle: AppTextStyles.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(manualTeachingProvider.notifier).discardTeaching();
              Navigator.pop(ctx);
            },
            child: Text('Discard', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.dangerRed)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text;
              final markerId = int.tryParse(markerIdController.text);
              ref.read(manualTeachingProvider.notifier).saveAsRoutine(name, markerId: markerId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Manual Routine saved'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: StadiumBorder(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(manualTeachingProvider);

    // Trigger save dialog when recording stops
    if (recordState.status == RecordingStatus.saving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSaveDialog(context);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text),
          onPressed: () {
            if (recordState.isRecording) {
              ref.read(manualTeachingProvider.notifier).stopTeaching();
            }
            context.pop();
          },
        ),
        title: Text(
          'Manual Teaching',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isSimulation = ref.watch(appConfigProvider).isSimulationMode;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSimulation ? AppColors.warningOrange.withOpacity(0.15) : AppColors.successGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSimulation ? AppColors.warningOrange.withOpacity(0.5) : AppColors.successGreen.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      isSimulation ? 'SIMULATION' : 'HARDWARE',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSimulation ? AppColors.warningOrange : AppColors.successGreen,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated Icon Container
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (recordState.isRecording ? AppColors.dangerRed : AppColors.primary).withOpacity(0.15),
                                      blurRadius: recordState.isRecording ? 30 : 15,
                                      spreadRadius: recordState.isRecording ? 10 : 3,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  AppIcons.training,
                                  size: 56,
                                  color: recordState.isRecording ? AppColors.dangerRed : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Title
                              Text(
                                recordState.isRecording ? 'Teaching in Progress' : 'Ready to Teach',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              // Subtitle
                              Text(
                                recordState.isRecording 
                                    ? 'Move the arm physically to record its path.\nPoints recorded: ${recordState.samples.length}'
                                    : 'Press Start to enter freewheel mode and record the arm\'s physical movements.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom Action Area
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (recordState.isRecording) ...[
                              // Recording Indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.dangerRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Recording...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.dangerRed,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Main Action Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (recordState.isRecording) {
                                    ref.read(manualTeachingProvider.notifier).stopTeaching();
                                  } else {
                                    ref.read(manualTeachingProvider.notifier).startTeaching();
                                  }
                                },
                                borderRadius: BorderRadius.circular(100),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    gradient: LinearGradient(
                                      colors: recordState.isRecording 
                                          ? [AppColors.dangerRed, AppColors.dangerRed.withOpacity(0.8)]
                                          : [AppColors.successGreen, const Color(0xFF16A34A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (recordState.isRecording ? AppColors.dangerRed : AppColors.successGreen).withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        recordState.isRecording ? Icons.stop_rounded : AppIcons.play,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        recordState.isRecording ? 'STOP TEACHING' : 'START TEACHING',
                                        style: AppTextStyles.titleLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
