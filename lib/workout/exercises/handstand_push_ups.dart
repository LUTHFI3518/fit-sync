import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Handstand Push-Ups (Wall Assisted): track depth and extension.
class HandstandPushUpsLogic extends BaseExercise {
  bool _isDown = false;

  HandstandPushUpsLogic(super.targetReps) {
    feedback = "Handstand against wall, lower head ↓";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWr = pose.landmarks[PoseLandmarkType.leftWrist];

    if (!conf([lShoulder, lElbow, lWr])) {
      feedback = "Show arm profile clearly";
      return;
    }

    final elbowAngle = angle(lShoulder!, lElbow!, lWr!);

    if (!_isDown && elbowAngle > 155) feedback = "Lower head controlled ↓";

    if (elbowAngle < 90) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Push back up ↑";
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
