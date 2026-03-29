import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class WorkoutController extends ChangeNotifier {
  final WorkoutService _service = WorkoutService();

  bool _isLoading = false;
  String? _error;
  bool _isAbsencePending = false;
  bool _isPaused = false;

  int totalDays = 90;
  int currentDay = 1;
  int streak = 0;
  int planMonths = 3; // default until loaded
  List<int> completedDays = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAbsencePending => _isAbsencePending;
  bool get isPaused => _isPaused;

  /// Human-readable plan label, e.g. "90-Day Journey" or "180-Day Journey"
  String get planLabel => '$totalDays-Day Journey';

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
      planMonths = data["planMonths"] ?? 3;
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
      _isAbsencePending = false;
      _isPaused = false;
      notifyListeners();

      final data = await _service.getTodayWorkout();
      todayWorkout = data;

      // Restore which exercises are already done from the session data
      if (data['completedExercises'] != null) {
        try {
          final List<dynamic> done = List.from(
            (data['completedExercises'] is String)
                ? jsonDecode(data['completedExercises'])
                : data['completedExercises'],
          );
          completedExerciseIds = done
              .map((e) => e['exerciseId'] as String)
              .toSet();
        } catch (_) {}
      }

      _error = null;
    } catch (e) {
      final errorStr = e.toString();
      _error = errorStr;
      
      // Specifically catch the absence_unresolved state
      if (errorStr.contains("You missed some days") || errorStr.contains("absence_unresolved")) {
        _isAbsencePending = true;
      }
      
      // Specifically catch the paused state
      if (errorStr.contains("paused")) {
        _isPaused = true;
      }
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

  Future<Map<String, dynamic>?> fetchExerciseInfo(String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final data = await _service.getExerciseInfo(name);
      return data;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
