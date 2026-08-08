import 'routine.dart';

/// State for the Motion Library — the list of all saved routines.
class MotionLibraryState {
  final List<Routine> routines;
  final String? defaultRoutineId;

  const MotionLibraryState({
    this.routines = const [],
    this.defaultRoutineId,
  });

  Routine? get defaultRoutine {
    if (defaultRoutineId == null) return null;
    try {
      return routines.firstWhere((r) => r.id == defaultRoutineId);
    } catch (_) {
      return null;
    }
  }

  MotionLibraryState copyWith({
    List<Routine>? routines,
    String? defaultRoutineId,
    bool clearDefault = false,
  }) {
    return MotionLibraryState(
      routines: routines ?? this.routines,
      defaultRoutineId: clearDefault ? null : (defaultRoutineId ?? this.defaultRoutineId),
    );
  }
}
