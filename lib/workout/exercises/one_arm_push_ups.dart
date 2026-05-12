import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// One-Arm Push-Up: only one arm bent. Track the active arm angle.
class OneArmPushUpsLogic extends BaseExercise {
  bool _isDown = false;

  OneArmPushUpsLogic(super.targetReps) {
    feedback = "One hand behind back, ready position";
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
      feedback = "Show the active arm clearly";
      return;
    }

    if (backOk) {
      final backAngle = angle(lShoulder!, lHip!, lAnkle!);
      if (backAngle < 155) {
        feedback = "Keep back straight & core tight!";
        return;
      }
    }

    // Track whichever arm shows more movement (lower angle = active arm)
    double lA = leftOk ? angle(lShoulder!, lElbow!, lWrist!) : 180.0;
    double rA = rightOk ? angle(rShoulder!, rElbow!, rWrist!) : 180.0;
    double activeAngle = lA < rA ? lA : rA;

    if (!_isDown && activeAngle > 160) feedback = "Lower body slowly ↓";

    if (activeAngle < 80) {
      if (!_isDown) { _isDown = true; feedback = "Drive up! ↑"; }
    }

    if (_isDown && activeAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
