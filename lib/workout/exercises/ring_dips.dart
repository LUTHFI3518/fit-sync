import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class RingDipsLogic extends BaseExercise {
  bool _isDown = false;

  RingDipsLogic(super.targetReps) {
    feedback = "Hold rings, arms straight, lean slightly";
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

    if (!leftOk || !rightOk) {
      feedback = "Both arms must be visible on rings";
      return;
    }

    final lA        = angle(lShoulder!, lElbow!, lWrist!);
    final rA        = angle(rShoulder!, rElbow!, rWrist!);
    final elbowAngle = (lA + rA) / 2;

    if (!_isDown && elbowAngle > 155) feedback = "Dip down controlled ↓";

    if (elbowAngle < 80) {
      if (!_isDown) { _isDown = true; feedback = "Press back up ↑"; }
    }

    if (_isDown && elbowAngle > 155) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
