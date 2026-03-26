import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class DumbellSideRiseLogic extends BaseExercise {
  bool _armsDown = true;

  DumbellSideRiseLogic(super.targetReps) {
    feedback = "Stand with arms at your sides";
  }

  @override
  void processPose(Pose pose) {
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];

    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];

    final leftOk = _conf(lElbow, lShoulder, lHip);
    final rightOk = _conf(rElbow, rShoulder, rHip);

    if (!leftOk && !rightOk) {
      feedback = "Step back to show torso and arms";
      return;
    }

    double angle = 0;
    if (leftOk && rightOk) {
      angle = (_angle(lElbow!, lShoulder!, lHip!) + _angle(rElbow!, rShoulder!, rHip!)) / 2;
    } else if (leftOk) {
      angle = _angle(lElbow!, lShoulder!, lHip!);
    } else {
      angle = _angle(rElbow!, rShoulder!, rHip!);
    }

    if (_armsDown && angle > 75) {
      _armsDown = false;
      feedback = "Lower arms \u2193";
    } else if (!_armsDown && angle < 35) {
      _armsDown = true;
      reps++;
      feedback = "Good range! Rep $reps \ud83d\udcaa";
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
    if (mag1 == 0 || mag2 == 0) return 0;
    return acos((dot / (mag1 * mag2)).clamp(-1.0, 1.0)) * 180 / pi;
  }
}
