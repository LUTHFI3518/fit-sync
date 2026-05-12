import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Dumbbell Front Raise: arms raised forward to shoulder height then lowered.
class DumbbellFrontRaiseLogic extends BaseExercise {
  bool _isUp = false;

  DumbbellFrontRaiseLogic(super.targetReps) {
    feedback = "Stand tall, dumbbells at thighs";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];
    final rHip      = pose.landmarks[PoseLandmarkType.rightHip];

    final leftOk  = conf([lShoulder, lWrist, lHip]);
    final rightOk = conf([rShoulder, rWrist, rHip]);

    if (!leftOk && !rightOk) {
      feedback = "Show full arms and torso in frame";
      return;
    }

    // No torso swing — check that hips stay well below shoulders
    if (leftOk && (lHip!.y - lShoulder!.y) < 80) {
      feedback = "Keep back straight — no swinging!";
      return;
    }

    // Raised = wrist at or above shoulder level (Y decreases upward in image coords)
    final lRaised = leftOk  && lWrist!.y <= lShoulder!.y + 20;
    final rRaised = rightOk && rWrist!.y <= rShoulder!.y + 20;

    // Lowered = wrist at or below hip level
    final lLowered = leftOk  && lWrist!.y >= lHip!.y - 20;
    final rLowered = rightOk && rWrist!.y >= rHip!.y - 20;

    if (!_isUp && (lRaised || rRaised)) {
      _isUp = true;
      feedback = "Lower slowly ↓";
    }

    if (_isUp && (lLowered || rLowered)) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp && !lRaised && !rRaised) {
      feedback = "Raise arms forward to shoulder height ↑";
    }
  }
}
