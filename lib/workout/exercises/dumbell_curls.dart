import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class DumbellCurlsLogic extends BaseExercise {
  bool _leftDown = true;
  bool _rightDown = true;

  DumbellCurlsLogic(super.targetReps) {
    feedback = "Stand straight and hold dumbells";
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
      feedback = "Upper body not in frame";
      return;
    }

    double lAngle = leftOk ? _angle(lShoulder!, lElbow!, lWrist!) : 180.0;
    double rAngle = rightOk ? _angle(rShoulder!, rElbow!, rWrist!) : 180.0;

    bool curled = false;

    if (leftOk) {
      if (_leftDown && lAngle < 60) {
        _leftDown = false;
        curled = true;
      } else if (!_leftDown && lAngle > 140) {
        _leftDown = true;
        feedback = "Curl left arm \u2191";
      }
    }

    if (rightOk) {
      if (_rightDown && rAngle < 60) {
        _rightDown = false;
        curled = true;
      } else if (!_rightDown && rAngle > 140) {
        _rightDown = true;
        if (!leftOk) feedback = "Curl right arm \u2191";
      }
    }

    if (curled) {
      reps++;
      feedback = "Nice curl! Rep $reps \ud83d\udcaa";
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
