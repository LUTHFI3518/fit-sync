import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class BulgarianSplitSquatWeightedLogic extends BaseExercise {
  bool _isDown = false;

  BulgarianSplitSquatWeightedLogic(super.targetReps) {
    feedback = "Dumbbells at sides, rear foot elevated";
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
      feedback = "Show full leg profile";
      return;
    }

    if (torsoOk) {
      final torsoAngle = angle(lShoulder!, lHip!, lKnee!);
      if (torsoAngle < 140) {
        feedback = "Stay upright — chest up!";
        return;
      }
    }

    double lA = leftOk ? angle(lHip!, lKnee!, lAnkle!) : 180.0;
    double rA = rightOk ? angle(rHip!, rKnee!, rAnkle!) : 180.0;
    double frontKneeAngle = lA < rA ? lA : rA;

    if (!_isDown && frontKneeAngle > 160) feedback = "Lower with control ↓";

    if (frontKneeAngle < 90) {
      if (!_isDown) { _isDown = true; feedback = "Drive back up ↑"; }
    }

    if (_isDown && frontKneeAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
