import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class PlankShoulderTapsLogic extends BaseExercise {
  DateTime? _holdStart;
  int _lastReportedSeconds = 0;

  PlankShoulderTapsLogic(super.targetReps) {
    feedback = "Plank Taps";
  }

  @override
  void processPose(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder] ?? pose.landmarks[PoseLandmarkType.rightShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip] ?? pose.landmarks[PoseLandmarkType.rightHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee] ?? pose.landmarks[PoseLandmarkType.rightKnee];

    if (!_conf(shoulder, hip, knee)) {
      _holdStart = null;
      feedback = "Show full side profile";
      return;
    }

    final angle = _angle(shoulder!, hip!, knee!);

    if (angle > 160) {
      _holdStart ??= DateTime.now();
      final elapsed = DateTime.now().difference(_holdStart!).inSeconds;

      if (elapsed != _lastReportedSeconds) {
        _lastReportedSeconds = elapsed;
        reps = elapsed;
        final remaining = targetReps - elapsed;
        if (remaining > 0) {
          feedback = "Hold! ${remaining}s to go \ud83d\udd25";
        } else {
          feedback = "Done! Great straight hold! \u2705";
        }
      }
    } else {
      _holdStart = null;
      _lastReportedSeconds = 0;
      feedback = "Keep your body straight!";
    }

  }

  bool _conf(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) =>
      a != null && b != null && c != null &&
      a.likelihood > 0.5 && b.likelihood > 0.5 && c.likelihood > 0.5;

  double _angle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
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
}
