import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// One-Arm Handstand Push-Ups (Free Standing): track depth and balance.
class HandstandPushUpsFreeLogic extends BaseExercise {
  bool _isDown = false;

  HandstandPushUpsFreeLogic(super.targetReps) {
    feedback = "Handstand, hold balance, lower head ↓";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWr = pose.landmarks[PoseLandmarkType.leftWrist];

    if (!conf([lShoulder, lElbow, lWr])) {
      feedback = "Show arm clearly for balance check";
      return;
    }

    final elbowAngle = angle(lShoulder!, lElbow!, lWr!);

    if (!_isDown && elbowAngle > 155) feedback = "Lower head controlled ↓";

    if (elbowAngle < 95) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Push up ↑";
      }
    }

    if (_isDown && elbowAngle > 160) {
      if (countRep()) {
        _isDown = false;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
