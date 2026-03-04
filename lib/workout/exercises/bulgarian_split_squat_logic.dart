import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Bulgarian Split Squat — front-leg knee angle (hip→knee→ankle).
/// The front leg is usually the left leg (or whichever is more visible).
/// Bottom = knee angle < 95°  /  Top = knee angle > 160°
class BulgarianSplitSquatLogic extends BaseExercise {
  bool _isDown = false;

  BulgarianSplitSquatLogic(super.targetReps) {
    feedback = "Stand with one leg forward, foot flat";
  }

  @override
  void processPose(Pose pose) {
    // Try left first, fall back to right
    final hip =
        pose.landmarks[PoseLandmarkType.leftHip] ??
        pose.landmarks[PoseLandmarkType.rightHip];
    final knee =
        pose.landmarks[PoseLandmarkType.leftKnee] ??
        pose.landmarks[PoseLandmarkType.rightKnee];
    final ankle =
        pose.landmarks[PoseLandmarkType.leftAnkle] ??
        pose.landmarks[PoseLandmarkType.rightAnkle];

    if (hip == null ||
        knee == null ||
        ankle == null ||
        hip.likelihood < 0.5 ||
        knee.likelihood < 0.5 ||
        ankle.likelihood < 0.5) {
      feedback = "Position yourself in frame";
      return;
    }

    final angle = _dot(hip, knee, ankle);

    if (!_isDown && angle > 160) {
      feedback = "Lunge down \u2193";
    }

    if (angle < 95) {
      _isDown = true;
      feedback = "Drive up through heel \u2191";
    }

    if (_isDown && angle > 160) {
      reps++;
      _isDown = false;
      feedback = "Rep $reps done! \ud83d\udcaa";
    }
  }

  double _dot(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
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
