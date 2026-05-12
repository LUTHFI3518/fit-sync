import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class OneArmTricepDipsLogic extends BaseExercise {
  bool _isDown = false;

  OneArmTricepDipsLogic(super.targetReps) {
    feedback = "One hand on surface, other behind back";
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
      feedback = "Show active arm clearly";
      return;
    }

    double lA = leftOk ? angle(lShoulder!, lElbow!, lWrist!) : 180.0;
    double rA = rightOk ? angle(rShoulder!, rElbow!, rWrist!) : 180.0;
    double activeAngle = lA < rA ? lA : rA;

    if (!_isDown && activeAngle > 155) feedback = "Dip down ↓";

    if (activeAngle < 80) {
      if (!_isDown) { _isDown = true; feedback = "Push back up ↑"; }
    }

    if (_isDown && activeAngle > 155) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
