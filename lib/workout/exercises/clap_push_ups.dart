import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Clap Push-Up: explosive pushup — uses same mechanics as standard.
/// Requires BOTH arms fully extended before clap phase.
class ClapPushUpsLogic extends BaseExercise {
  bool _isDown = false;

  ClapPushUpsLogic(super.targetReps) {
    feedback = "Get into pushup position";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow    = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle    = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow    = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftOk  = conf([lShoulder, lElbow, lWrist]);
    final rightOk = conf([rShoulder, rElbow, rWrist]);
    final backOk  = conf([lShoulder, lHip, lAnkle]);

    if (!leftOk && !rightOk) {
      feedback = "Full upper body must be in frame";
      return;
    }

    if (backOk) {
      final backAngle = angle(lShoulder!, lHip!, lAnkle!);
      if (backAngle < 155) {
        feedback = "Keep back straight!";
        return;
      }
    }

    // Require BOTH arms visible for clap push-up
    if (!leftOk || !rightOk) {
      feedback = "Both arms must be visible";
      return;
    }

    final lA = angle(lShoulder!, lElbow!, lWrist!);
    final rA = angle(rShoulder!, rElbow!, rWrist!);
    final elbowAngle = (lA + rA) / 2;

    if (!_isDown && elbowAngle > 160) feedback = "Go down fast ↓";

    if (elbowAngle < 75) {
      if (!_isDown) { _isDown = true; feedback = "Explode up & clap! ↑"; }
    }

    // Count rep only on clean return to full extension
    if (_isDown && elbowAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Clap! Rep $reps 💪"; }
    }
  }
}
