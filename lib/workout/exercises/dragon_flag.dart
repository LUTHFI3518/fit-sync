import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Dragon Flag: lying, body held rigid and lowered/raised as one unit.
/// Detect hip angle dropping (lowering) then returning to flat.
class DragonFlagLogic extends BaseExercise {
  bool _isDown = false;

  DragonFlagLogic(super.targetReps) {
    feedback = "Grip overhead, body straight";
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
      feedback = "Show full body side profile";
      return;
    }

    double bodyAngle;
    if (leftOk && rightOk) {
      bodyAngle = (angle(lShoulder!, lHip!, lAnkle!) + angle(rShoulder!, rHip!, rAnkle!)) / 2;
    } else if (leftOk) {
      bodyAngle = angle(lShoulder!, lHip!, lAnkle!);
    } else {
      bodyAngle = angle(rShoulder!, rHip!, rAnkle!);
    }

    // Body must stay rigid (hip angle > 155° = body straight)
    if (bodyAngle < 145) {
      feedback = "Keep body rigid — don't bend hips!";
      return;
    }

    // The "flag" lowers when ankles drop relative to shoulders
    // We approximate by tracking if the body is angled down vs horizontal
    final refShoulder = leftOk ? lShoulder! : rShoulder!;
    final refAnkle    = leftOk ? lAnkle!    : rAnkle!;

    // Positive = ankles below shoulder (lowered), Negative = ankles above (raised)
    final verticalDiff = refAnkle.y - refShoulder.y;

    if (!_isDown && verticalDiff > 50) {
      _isDown = true;
      feedback = "Raise back up ↑";
    }

    if (_isDown && verticalDiff < -20) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isDown && verticalDiff < 20) {
      feedback = "Lower body slowly ↓";
    }
  }
}
