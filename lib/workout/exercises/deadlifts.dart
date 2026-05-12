import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Deadlift: requires clear hip hinge and locking out.
class DeadliftsLogic extends BaseExercise {
  bool _isDown = false;

  DeadliftsLogic(super.targetReps) {
    feedback = "Stand with feet hip-width, grip bar";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (!conf([lShoulder, lHip, lAnkle])) {
      feedback = "Show full side profile from floor up";
      return;
    }

    // Measure hip hinge angle (Shoulder-Hip-Ankle)
    final hingeAngle = angle(lShoulder!, lHip!, lAnkle!);

    // Down: significant hip hinge (< 110°)
    if (!_isDown && hingeAngle < 110) {
      _isDown = true;
      feedback = "Drive through heels and lock out ↑";
    }

    // Up: full lockout (> 160°)
    if (_isDown && hingeAngle > 160) {
      if (countRep()) {
        _isDown = false;
        feedback = "Rep $reps 💪";
      }
    }

    if (!_isDown && hingeAngle > 165) {
      feedback = "Hinge at the hips down ↓";
    }
  }
}
