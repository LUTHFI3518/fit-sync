import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class DeadliftsLogic extends BaseExercise {
  bool _isDown = false;

  DeadliftsLogic(super.targetReps) {
    feedback = "Deadlifts";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    final leftOk = _conf(lShoulder, lHip, lKnee);
    final rightOk = _conf(rShoulder, rHip, rKnee);

    if (!leftOk && !rightOk) {
      feedback = "Make sure full profile is in frame";
      return;
    }

    double angle = 0;
    if (leftOk && rightOk) {
      angle = (_angle(lShoulder!, lHip!, lKnee!) + _angle(rShoulder!, rHip!, rKnee!)) / 2;
    } else if (leftOk) {
      angle = _angle(lShoulder!, lHip!, lKnee!);
    } else {
      angle = _angle(rShoulder!, rHip!, rKnee!);
    }

    if (!_isDown && angle > 160) {
      feedback = "Hinge hips down \u2193";
    }

    if (angle < 110) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Pull up \u2191";
      }
    }

    if (_isDown && angle > 160) {
      reps++;
      _isDown = false;
      feedback = "Good hinge! Rep $reps \ud83d\udcaa";
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
