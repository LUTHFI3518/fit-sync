import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Hanging Leg Raises: legs straight, lifted to horizontal or above.
class HangingLegRaisesLogic extends BaseExercise {
  bool _isUp = false;

  HangingLegRaisesLogic(super.targetReps) {
    feedback = "Hang from bar, keep legs straight";
  }

  @override
  void processPose(Pose pose) {
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle    = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (!conf([lWrist, lShoulder, lHip, lAnkle])) {
      feedback = "Show full body — wrists to ankles";
      return;
    }

    // Grip check
    if (lWrist!.y > lShoulder!.y) {
      feedback = "Hands must be above — hang from bar!";
      return;
    }

    // Leg straightness: knee must not be bent (hip-to-ankle angle via hip)
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    if (conf([lHip, lKnee, lAnkle])) {
      final kneeAngle = angle(lHip!, lKnee!, lAnkle!);
      if (kneeAngle < 155) {
        feedback = "Keep legs straight!";
        return;
      }
    }

    final hipAngle = angle(lShoulder, lHip!, lAnkle!);

    // Legs raised = hip angle < 90° (horizontal or above)
    if (!_isUp && hipAngle < 95) {
      _isUp = true;
      feedback = "Lower legs slowly ↓";
    }

    if (_isUp && hipAngle > 165) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp && hipAngle > 165) {
      feedback = "Raise legs straight up ↑";
    }
  }
}
