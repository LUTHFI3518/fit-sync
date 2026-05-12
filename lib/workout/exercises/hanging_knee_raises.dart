import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Hanging Knee Raises: wrists above shoulders, knees drawn up.
class HangingKneeRaisesLogic extends BaseExercise {
  bool _isUp = false;

  HangingKneeRaisesLogic(super.targetReps) {
    feedback = "Hang from bar, arms extended";
  }

  @override
  void processPose(Pose pose) {
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee     = pose.landmarks[PoseLandmarkType.leftKnee];

    if (!conf([lWrist, lShoulder, lHip, lKnee])) {
      feedback = "Show full body — wrists to knees";
      return;
    }

    // Grip check: wrists must be above shoulders (hanging position)
    if (lWrist!.y > lShoulder!.y) {
      feedback = "Hands must be above — hang from bar!";
      return;
    }

    final hipAngle = angle(lShoulder, lHip!, lKnee!);

    if (!_isUp && hipAngle < 90) {
      _isUp = true;
      feedback = "Lower knees slowly ↓";
    }

    if (_isUp && hipAngle > 160) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp && hipAngle > 160) {
      feedback = "Pull knees up ↑";
    }
  }
}
