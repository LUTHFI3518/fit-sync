import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class BarbellOverheadPressLogic extends BaseExercise {
  bool _isUp = false;

  BarbellOverheadPressLogic(super.targetReps) {
    feedback = "Bar at shoulders, feet hip-width";
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
    final armsFullyUp = lWrist.y < lShoulder.y - 20 && rWrist.y < rShoulder.y - 20;

    if (!_isUp && armsFullyUp && avgAngle > 165) {
      _isUp = true;
      feedback = "Lower bar to shoulders ↓";
    }

    if (_isUp && avgAngle < 95) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp) feedback = "Press bar overhead fully ↑";
  }
}
