import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Lateral Raise: wrists rise to shoulder height, then lower.
class DumbellSideRiseLogic extends BaseExercise {
  bool _isUp = false;

  DumbellSideRiseLogic(super.targetReps) {
    feedback = "Arms at sides, palms facing in";
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
      feedback = "Show arms and shoulders in frame";
      return;
    }

    // Raised: wrists at or above shoulder level
    final lRaised = leftOk  && lWrist!.y <= lShoulder!.y + 15;
    final rRaised = rightOk && rWrist!.y <= rShoulder!.y + 15;

    // Lowered: wrists at or below hip level
    final lLowered = leftOk  && lWrist!.y >= lHip!.y - 20;
    final rLowered = rightOk && rWrist!.y >= rHip!.y - 20;

    if (!_isUp && (lRaised || rRaised)) {
      _isUp = true;
      feedback = "Lower arms slowly ↓";
    }

    if (_isUp && (lLowered || rLowered)) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp && !lRaised && !rRaised) {
      feedback = "Raise arms out to shoulder level ↑";
    }
  }
}
