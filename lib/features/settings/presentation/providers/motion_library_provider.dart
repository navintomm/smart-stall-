import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/routine.dart';
import '../../domain/models/motion_library_state.dart';

final motionLibraryProvider =
    StateNotifierProvider<MotionLibraryNotifier, MotionLibraryState>((ref) {
  return MotionLibraryNotifier();
});

class MotionLibraryNotifier extends StateNotifier<MotionLibraryState> {
  MotionLibraryNotifier() : super(const MotionLibraryState());

  /// Add a new routine (called after recording is saved).
  void saveRoutine(Routine routine) {
    state = state.copyWith(routines: [...state.routines, routine]);
    // Auto-set as default if it's the first routine
    if (state.routines.length == 1) {
      state = state.copyWith(defaultRoutineId: routine.id);
    }
  }

  /// Rename an existing routine.
  void rename(String id, String newName) {
    state = state.copyWith(
      routines: state.routines
          .map((r) => r.id == id ? r.copyWith(name: newName) : r)
          .toList(),
    );
  }

  /// Delete a routine by id.
  void delete(String id) {
    final updated = state.routines.where((r) => r.id != id).toList();
    final newDefault = state.defaultRoutineId == id
        ? (updated.isEmpty ? null : updated.first.id)
        : state.defaultRoutineId;
    state = MotionLibraryState(
      routines: updated,
      defaultRoutineId: newDefault,
    );
  }

  /// Duplicate a routine with a new id and "(Copy)" suffix.
  void duplicate(String id) {
    final original = state.routines.firstWhere((r) => r.id == id);
    final copy = original.copyWith(
      id: 'routine_${DateTime.now().millisecondsSinceEpoch}',
      name: '${original.name} (Copy)',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(routines: [...state.routines, copy]);
  }

  /// Set the default routine shown on the Home screen.
  void setDefault(String id) {
    state = state.copyWith(defaultRoutineId: id);
  }
}
