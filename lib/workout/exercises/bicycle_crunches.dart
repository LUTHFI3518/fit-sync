import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class BicycleCrunchesLogic extends BaseExercise {
  int _state = 0; // 0=neutral, 1=left elbow crunch, 2=right elbow crunch

  BicycleCrunchesLogic(super.targetReps) {
    feedback = "Lie down, hands behind head";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (!_conf(lShoulder, lHip, lKnee) && !_conf(rShoulder, rHip, rKnee)) {
      feedback = "Position full body in frame";
      return;
    }

    final lHipAngle = _conf(lShoulder, lHip, lKnee) ? _angle(lShoulder!, lHip!, lKnee!) : 180.0;
    final rHipAngle = _conf(rShoulder, rHip, rKnee) ? _angle(rShoulder!, rHip!, rKnee!) : 180.0;

    // Crunch detection: Hip angle drops below 100 degrees
    if (_state != 1 && rHipAngle < 100 && lHipAngle > 110) {
      _state = 1;
      feedback = "Switch side \u2194";
    } else if (_state != 2 && lHipAngle < 100 && rHipAngle > 110) {
      _state = 2;
      reps++;
      feedback = "Great! Rep $reps \ud83d\udcaa";
    } else if (lHipAngle > 140 && rHipAngle > 140) {
      if (_state != 0) {
         _state = 0;
         feedback = "Keep alternating";
      }
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
