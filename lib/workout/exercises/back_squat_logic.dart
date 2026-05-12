import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class BackSquatLogic extends BaseExercise {
  bool _isDown = false;

  BackSquatLogic(super.targetReps) {
    feedback = "Stand tall, feet shoulder-width apart";
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

    final leftOk   = conf([lHip, lKnee, lAnkle]);
    final rightOk  = conf([rHip, rKnee, rAnkle]);
    final torsoOk  = conf([lShoulder, lHip, lKnee]);

    if (!leftOk && !rightOk) {
      feedback = "Step sideways so camera sees your full legs";
      return;
    }

    // 1. Torso upright check — no hunching
    if (torsoOk) {
      final torsoAngle = angle(lShoulder!, lHip!, lKnee!);
      if (torsoAngle < 130) {
        feedback = "Keep your chest up — don't hunch!";
        return;
      }
    }

    // 2. Knee angle
    double kneeAngle;
    if (leftOk && rightOk) {
      kneeAngle = (angle(lHip!, lKnee!, lAnkle!) + angle(rHip!, rKnee!, rAnkle!)) / 2;
    } else if (leftOk) {
      kneeAngle = angle(lHip!, lKnee!, lAnkle!);
    } else {
      kneeAngle = angle(rHip!, rKnee!, rAnkle!);
    }

    if (!_isDown && kneeAngle > 165) feedback = "Squat down ↓";

    // Must reach parallel (90°) for rep to count
    if (kneeAngle < 90) {
      if (!_isDown) { _isDown = true; feedback = "Good depth! Stand up ↑"; }
    }

    if (_isDown && kneeAngle > 165) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
