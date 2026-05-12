import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class BaseExercise {
  int reps = 0;
  int targetReps;
  String feedback = "Get ready";

  // Shared confidence threshold — raised from 0.5 to 0.65 for all exercises
  static const double kConf = 0.65;

  // Debounce: prevents double-counting a rep within 600ms
  DateTime? _lastRepTime;

  BaseExercise(this.targetReps);

  void processPose(Pose pose);

  bool get isCompleted => reps >= targetReps;

  /// Returns true if all landmarks are detected with sufficient confidence.
  bool conf(List<PoseLandmark?> landmarks) {
    for (final lm in landmarks) {
      if (lm == null || lm.likelihood < kConf) return false;
    }
    return true;
  }

  /// Calculates the angle at point [b] formed by vectors b→a and b→c.
  double angle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final v1x = a.x - b.x;
    final v1y = a.y - b.y;
    final v2x = c.x - b.x;
    final v2y = c.y - b.y;
    final dot = v1x * v2x + v1y * v2y;
    final mag1 = sqrt(v1x * v1x + v1y * v1y);
    final mag2 = sqrt(v2x * v2x + v2y * v2y);
    if (mag1 == 0 || mag2 == 0) return 180;
    return acos((dot / (mag1 * mag2)).clamp(-1.0, 1.0)) * 180 / pi;
  }

  /// Call this to safely count a rep with debounce protection.
  /// Returns true if the rep was counted, false if debounced.
  bool countRep() {
    final now = DateTime.now();
    if (_lastRepTime != null &&
        now.difference(_lastRepTime!).inMilliseconds < 600) {
      return false; // Too soon — ignore
    }
    _lastRepTime = now;
    reps++;
    return true;
  }
}
