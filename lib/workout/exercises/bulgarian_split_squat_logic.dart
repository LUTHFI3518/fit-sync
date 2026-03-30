import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class BulgarianSplitSquatLogic extends BaseExercise {
  bool _isDown = false;

  BulgarianSplitSquatLogic(super.targetReps) {
    feedback = "Rear foot elevated, front foot forward";
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
    final torsoOk = conf([lShoulder, lHip, lKnee]);

    if (!leftOk && !rightOk) {
      feedback = "Show full leg & side profile";
      return;
    }

    if (torsoOk) {
      final torsoAngle = angle(lShoulder!, lHip!, lKnee!);
      if (torsoAngle < 140) {
        feedback = "Stay upright — don't lean forward!";
        return;
      }
    }

    // Use front leg (whichever has sharper angle)
    double lA = leftOk ? angle(lHip!, lKnee!, lAnkle!) : 180.0;
    double rA = rightOk ? angle(rHip!, rKnee!, rAnkle!) : 180.0;
    double frontKneeAngle = lA < rA ? lA : rA;

    if (!_isDown && frontKneeAngle > 160) feedback = "Lower into split squat ↓";

    if (frontKneeAngle < 90) {
      if (!_isDown) { _isDown = true; feedback = "Drive back up ↑"; }
    }

    if (_isDown && frontKneeAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
