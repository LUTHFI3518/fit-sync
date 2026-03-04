import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class PushUpLogic extends BaseExercise {
  bool _isDown = false;

  PushUpLogic(super.targetReps) {
    feedback = "Get into position";
  }

  @override
  void processPose(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];

    if (shoulder == null || elbow == null || wrist == null) {
      feedback = "Position yourself in frame";
      return;
    }

    // Reject landmarks with low detection confidence to avoid false counts
    if (shoulder.likelihood < 0.5 ||
        elbow.likelihood < 0.5 ||
        wrist.likelihood < 0.5) {
      feedback = "Hold still, detecting...";
      return;
    }

    final angle = _calculateAngle(shoulder, elbow, wrist);

    if (!_isDown && angle > 155) {
      feedback = "Go down \u2193";
    }

    if (angle < 70) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Push up \u2191";
      }
    }

    if (_isDown && angle > 155) {
      reps++;
      _isDown = false;
      feedback = "Great! Rep $reps \ud83d\udcaa";
    }
  }

  /// Uses the dot-product (law of cosines) method to compute the
  /// interior angle at joint [b], between rays b->a and b->c.
  /// This gives the true anatomical joint angle (0-180 degrees).
  double _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final v1x = a.x - b.x;
    final v1y = a.y - b.y;
    final v2x = c.x - b.x;
    final v2y = c.y - b.y;

    final dot = v1x * v2x + v1y * v2y;
    final mag1 = sqrt(v1x * v1x + v1y * v1y);
    final mag2 = sqrt(v2x * v2x + v2y * v2y);

    if (mag1 == 0 || mag2 == 0) return 0;

    final cosAngle = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return acos(cosAngle) * 180 / pi;
  }
}
