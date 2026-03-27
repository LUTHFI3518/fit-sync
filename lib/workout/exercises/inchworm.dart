import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class InchwormLogic extends BaseExercise {
  int _state = 0; // 0 = standing, 1 = plank extended

  InchwormLogic(super.targetReps) {
    feedback = "Stand up straight to begin";
  }

  @override
  void processPose(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];

    if (!_conf(shoulder, hip, ankle) || wrist == null || wrist.likelihood < 0.5) {
      feedback = "Keep side profile strictly in frame";
      return;
    }

    final hipAngle = _angle(shoulder!, hip!, ankle!);
    final torsoLen = _dist(shoulder, hip);
    final handToFoot = _dist(wrist, ankle);

    // If hands are further than 1.5x torso length from feet, we're in plank out
    if (_state == 0 && hipAngle > 150 && handToFoot > torsoLen * 1.5) {
      _state = 1;
      feedback = "Walk hands back \u2190";
    } 
    // If standing straight again and hands close to feet or body
    else if (_state == 1 && hipAngle > 160 && handToFoot < torsoLen * 1.5) {
      reps++;
      _state = 0;
      feedback = "Great stretch! Rep $reps \ud83d\udcaa";
    } else if (_state == 0 && hipAngle < 120) {
      feedback = "Walk hands forward \u2192";
    }
  }

  bool _conf(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) =>
      a != null && b != null && c != null &&
      a.likelihood > 0.5 && b.likelihood > 0.5 && c.likelihood > 0.5;

  double _dist(PoseLandmark a, PoseLandmark b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
  }

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
