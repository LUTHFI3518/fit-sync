import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Back Squat — side view camera recommended.
/// Measures the knee angle (hip→knee→ankle).
/// Full squat = knee angle < 90°  /  Standing = knee angle > 165°
class BackSquatLogic extends BaseExercise {
  bool _isDown = false;

  BackSquatLogic(super.targetReps) {
    feedback = "Stand tall, feet shoulder-width apart";
  }

  @override
  void processPose(Pose pose) {
    // Use BOTH legs; prefer whichever is more confident
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final leftOk = _confident(lHip, lKnee, lAnkle);
    final rightOk = _confident(rHip, rKnee, rAnkle);

    if (!leftOk && !rightOk) {
      feedback = "Step sideways so camera sees your legs";
      return;
    }

    // Average of both angles if both available, otherwise whichever is visible
    double angle;
    if (leftOk && rightOk) {
      angle = (_dot(lHip!, lKnee!, lAnkle!) + _dot(rHip!, rKnee!, rAnkle!)) / 2;
    } else if (leftOk) {
      angle = _dot(lHip!, lKnee!, lAnkle!);
    } else {
      angle = _dot(rHip!, rKnee!, rAnkle!);
    }

    if (!_isDown && angle > 165) {
      feedback = "Squat down \u2193";
    }

    if (angle < 90) {
      _isDown = true;
      feedback = "Good depth! Stand up \u2191";
    }

    if (_isDown && angle > 165) {
      reps++;
      _isDown = false;
      feedback = "Nice squat! Rep $reps \ud83d\udcaa";
    }
  }

  bool _confident(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) =>
      a != null &&
      b != null &&
      c != null &&
      a.likelihood > 0.5 &&
      b.likelihood > 0.5 &&
      c.likelihood > 0.5;

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
