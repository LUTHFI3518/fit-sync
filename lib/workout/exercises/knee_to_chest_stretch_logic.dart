import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Knee to Chest Stretch: requires pull knee to chest and lowering.
class KneeToChestLogic extends BaseExercise {
  bool _isUp = false;

  KneeToChestLogic(super.targetReps) {
    feedback = "Lie on your back, pull one knee to chest";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (!conf([lShoulder, lHip, lKnee])) {
      feedback = "Show full side profile lying flat";
      return;
    }

    // Measure hip angle
    final hipAngle = angle(lShoulder!, lHip!, lKnee!);

    // Pull: knee angle must reach < 70° (deep pull)
    if (!_isUp && hipAngle < 70) {
      _isUp = true;
      feedback = "Now lower leg slowly ↓";
    }

    if (_isUp && hipAngle > 140) {
      if (countRep()) {
        _isUp = false;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
