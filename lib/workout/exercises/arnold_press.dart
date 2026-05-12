import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Arnold Press: seated/standing dumbbell overhead press with rotation.
/// Track both arms reaching full extension overhead.
class ArnoldPressLogic extends BaseExercise {
  bool _isUp = false;

  ArnoldPressLogic(super.targetReps) {
    feedback = "Dumbbells at shoulder level, palms in";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow    = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow    = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];

    if (!conf([lShoulder, lElbow, lWrist]) || !conf([rShoulder, rElbow, rWrist])) {
      feedback = "Both arms must be visible";
      return;
    }

    final lA = angle(lShoulder!, lElbow!, lWrist!);
    final rA = angle(rShoulder!, rElbow!, rWrist!);
    final avgAngle = (lA + rA) / 2;

    // Fully pressed = both arms extended overhead (> 165°)
    // Both wrists above shoulders
    final armsUp = lWrist.y < lShoulder.y && rWrist.y < rShoulder.y;

    if (!_isUp && armsUp && avgAngle > 165) {
      _isUp = true;
      feedback = "Lower with rotation ↓";
    }

    // Starting position: elbows bent ~90°, wrists at shoulder level
    if (_isUp && avgAngle < 100 && !armsUp) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp) feedback = "Press overhead fully ↑";
  }
}
