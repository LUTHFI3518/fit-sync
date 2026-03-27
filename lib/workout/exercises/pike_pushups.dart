import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class PikePushupsLogic extends BaseExercise {
  bool _isDown = false;

  PikePushupsLogic(super.targetReps) {
    feedback = "Get into an inverted V position";
  }

  @override
  void processPose(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (!_conf(shoulder, elbow, wrist) || !_conf(shoulder, hip, ankle)) {
      feedback = "Position full body in frame";
      return;
    }

    final hipAngle = _angle(shoulder!, hip!, ankle!);
    if (hipAngle > 130) {
      feedback = "Raise your hips higher into a V";
      return;
    }

    final armAngle = _angle(shoulder, elbow!, wrist!);

    if (!_isDown && armAngle > 140) {
      feedback = "Lower your head \u2193";
    }

    if (armAngle < 85) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Push back up \u2191";
      }
    }

    if (_isDown && armAngle > 140) {
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
