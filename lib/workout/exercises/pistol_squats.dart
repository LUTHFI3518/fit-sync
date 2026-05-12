import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Pistol Squat: single-leg squat. Track the bent leg (smaller knee angle).
class PistolSquatsLogic extends BaseExercise {
  bool _isDown = false;

  PistolSquatsLogic(super.targetReps) {
    feedback = "Balance on one leg, extend other forward";
  }

  @override
  void processPose(Pose pose) {
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee     = pose.landmarks[PoseLandmarkType.leftKnee];
    final lAnkle    = pose.landmarks[PoseLandmarkType.leftAnkle];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rHip      = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee     = pose.landmarks[PoseLandmarkType.rightKnee];
    final rAnkle    = pose.landmarks[PoseLandmarkType.rightAnkle];

    final leftOk  = conf([lHip, lKnee, lAnkle]);
    final rightOk = conf([rHip, rKnee, rAnkle]);
    final torsoOk = conf([lShoulder, lHip]);

    if (!leftOk && !rightOk) {
      feedback = "Show full leg profile";
      return;
    }

    if (torsoOk) {
      // Hip must stay above knee — no collapsing
      if (lHip!.y > lKnee!.y + 30) {
        feedback = "Keep chest up, don't collapse!";
        return;
      }
    }

    // Stand leg = the one more bent
    double lA = leftOk ? angle(lHip!, lKnee!, lAnkle!) : 180.0;
    double rA = rightOk ? angle(rHip!, rKnee!, rAnkle!) : 180.0;
    double standLegAngle = lA < rA ? lA : rA;

    if (!_isDown && standLegAngle > 160) feedback = "Squat on one leg ↓";

    if (standLegAngle < 80) {
      if (!_isDown) { _isDown = true; feedback = "Full depth! Rise ↑"; }
    }

    if (_isDown && standLegAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
