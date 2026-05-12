import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Superman Pull: lie prone, lift arms and legs simultaneously.
class SupermanPullsLogic extends BaseExercise {
  bool _isUp = false;

  SupermanPullsLogic(super.targetReps) {
    feedback = "Lie face down, arms extended forward";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle    = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (!conf([lShoulder, lWrist, lHip, lAnkle])) {
      feedback = "Show full body side profile";
      return;
    }

    // Detect lift: wrists and ankles rise above hips in image space
    final wristAboveHip = lWrist!.y < lHip!.y;
    final ankleAboveHip = lAnkle!.y < lHip.y;

    if (!_isUp && wristAboveHip && ankleAboveHip) {
      _isUp = true;
      feedback = "Hold briefly, then lower ↓";
    }

    if (_isUp && !wristAboveHip && !ankleAboveHip) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp && !wristAboveHip) {
      feedback = "Lift arms and legs simultaneously ↑";
    }
  }
}
