import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class OverheadTricepExtensionLogic extends BaseExercise {
  bool _isDown = false;

  OverheadTricepExtensionLogic(super.targetReps) {
    feedback = "Overhead Tricep Ex";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    final leftOk = _conf(lShoulder, lElbow, lWrist);

    if (!leftOk) {
      feedback = "Make sure arms are in frame";
      return;
    }

    final angle = _angle(lShoulder!, lElbow!, lWrist!);

    if (!_isDown && angle < 90) {
      feedback = "Press up \u2191";
    }

    if (angle > 150) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Lower down \u2193";
      }
    }

    if (_isDown && angle < 90) {
      reps++;
      _isDown = false;
      feedback = "Rep $reps \ud83d\udcaa";
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
