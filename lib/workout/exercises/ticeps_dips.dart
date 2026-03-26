import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class TicepsDipsLogic extends BaseExercise {
  bool _isDown = false;

  TicepsDipsLogic(super.targetReps) {
    feedback = "Hands behind on surface, start dips";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftOk = _conf(lShoulder, lElbow, lWrist);
    final rightOk = _conf(rShoulder, rElbow, rWrist);

    if (!leftOk && !rightOk) {
      feedback = "Make sure arms are in frame";
      return;
    }

    double angle = 0;
    if (leftOk && rightOk) {
      angle = (_angle(lShoulder!, lElbow!, lWrist!) + _angle(rShoulder!, rElbow!, rWrist!)) / 2;
    } else if (leftOk) {
      angle = _angle(lShoulder!, lElbow!, lWrist!);
    } else {
      angle = _angle(rShoulder!, rElbow!, rWrist!);
    }

    if (!_isDown && angle > 150) {
      feedback = "Lower body \u2193";
    }

    if (angle < 90) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Push back up \u2191";
      }
    }

    if (_isDown && angle > 150) {
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
