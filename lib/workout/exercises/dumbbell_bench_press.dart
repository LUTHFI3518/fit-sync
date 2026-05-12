import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class DumbbellBenchPressLogic extends BaseExercise {
  bool _isDown = false;

  DumbbellBenchPressLogic(super.targetReps) {
    feedback = "Lie on bench, dumbbells at chest";
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
      feedback = "Both arms must be clearly visible";
      return;
    }

    final lA = angle(lShoulder!, lElbow!, lWrist!);
    final rA = angle(rShoulder!, rElbow!, rWrist!);
    final avgAngle = (lA + rA) / 2;

    if (!_isDown && avgAngle > 160) feedback = "Lower dumbbells to chest ↓";

    // Lowered: elbows bent ~80°
    if (avgAngle < 80) {
      if (!_isDown) { _isDown = true; feedback = "Press up ↑"; }
    }

    if (_isDown && avgAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
