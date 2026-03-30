import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Overhead Tricep Extension: arms overhead, bend at elbow, extend.
class OverheadTricepExtensionLogic extends BaseExercise {
  bool _isDown = false;

  OverheadTricepExtensionLogic(super.targetReps) {
    feedback = "Arms overhead, elbows pointing up";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow    = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow    = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftOk  = conf([lShoulder, lElbow, lWrist]);
    final rightOk = conf([rShoulder, rElbow, rWrist]);

    if (!leftOk && !rightOk) {
      feedback = "Show arms overhead in frame";
      return;
    }

    // Elbows must be above shoulders (overhead position)
    if (leftOk && lElbow!.y > lShoulder!.y) {
      feedback = "Keep elbows up and pointing forward!";
      return;
    }

    double elbowAngle;
    if (leftOk && rightOk) {
      elbowAngle = (angle(lShoulder!, lElbow!, lWrist!) +
                    angle(rShoulder!, rElbow!, rWrist!)) / 2;
    } else if (leftOk) {
      elbowAngle = angle(lShoulder!, lElbow!, lWrist!);
    } else {
      elbowAngle = angle(rShoulder!, rElbow!, rWrist!);
    }

    if (!_isDown && elbowAngle > 160) feedback = "Lower weight behind head ↓";

    if (elbowAngle < 75) {
      if (!_isDown) { _isDown = true; feedback = "Extend arms up ↑"; }
    }

    if (_isDown && elbowAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
