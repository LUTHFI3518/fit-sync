import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Leg Raises: lying flat, raise both legs to ~90° then lower.
class LegRisesLogic extends BaseExercise {
  bool _legsUp = false;

  LegRisesLogic(super.targetReps) {
    feedback = "Lie flat on your back, legs straight";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle    = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rHip      = pose.landmarks[PoseLandmarkType.rightHip];
    final rAnkle    = pose.landmarks[PoseLandmarkType.rightAnkle];

    final leftOk  = conf([lShoulder, lHip, lAnkle]);
    final rightOk = conf([rShoulder, rHip, rAnkle]);

    if (!leftOk && !rightOk) {
      feedback = "Show full side profile";
      return;
    }

    // Average hip angle from both sides if available
    double hipAngle;
    if (leftOk && rightOk) {
      hipAngle = (angle(lShoulder!, lHip!, lAnkle!) + angle(rShoulder!, rHip!, rAnkle!)) / 2;
    } else if (leftOk) {
      hipAngle = angle(lShoulder!, lHip!, lAnkle!);
    } else {
      hipAngle = angle(rShoulder!, rHip!, rAnkle!);
    }

    // Lift: hip angle must reach < 100° (legs near vertical)
    if (!_legsUp && hipAngle < 100) {
      _legsUp = true;
      feedback = "Lower legs slowly ↓";
    } else if (_legsUp && hipAngle > 165) {
      // Legs fully lowered
      if (countRep()) {
        _legsUp = false;
        feedback = "Rep $reps 💪";
      }
    } else if (!_legsUp && hipAngle > 165) {
      feedback = "Raise both legs ↑";
    }
  }
}
