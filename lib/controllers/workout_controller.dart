import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class WorkoutController extends ChangeNotifier {
  final WorkoutService _service = WorkoutService();

  bool _isLoading = false;
  String? _error;

  int totalDays = 90;
  int currentDay = 1;
  int streak = 0;
  List<int> completedDays = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic>? todayWorkout;

  /// IDs of exercises completed in the current session (persisted in todayWorkout)
  Set<String> completedExerciseIds = {};

  Future<void> loadJourney() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.getJourney();

      totalDays = data["totalDays"];
      currentDay = data["currentDay"];
      streak = data["streak"];
      completedDays = List<int>.from(data["completedDays"]);

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayWorkout() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.getTodayWorkout();
      todayWorkout = data;

      // Restore which exercises are already done from the session data
      if (data['completedExercises'] != null) {
        try {
          final List<dynamic> done = List.from(
            (data['completedExercises'] is String)
                ? [] // will parse below
                : data['completedExercises'],
          );
          completedExerciseIds = done
              .map((e) => e['exerciseId'] as String)
              .toSet();
        } catch (_) {}
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marks one exercise as done. Returns `true` if the full day is now complete.
  Future<bool> markExerciseDone({
    required String exerciseId,
    required int repsCompleted,
  }) async {
    try {
      final result = await _service.completeExercise(
        exerciseId: exerciseId,
        repsCompleted: repsCompleted,
      );

      completedExerciseIds.add(exerciseId);
      notifyListeners();

      final allDone = result['allDone'] == true;
      if (allDone) {
        // Refresh the journey so the day node turns green
        await loadJourney();
      }
      return allDone;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
