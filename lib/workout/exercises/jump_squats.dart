import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Jump Squat: requires descent to parallel AND re-extension to standing.
/// The jump phase naturally forces full extension.
class JumpSquatsLogic extends BaseExercise {
  bool _isDown = false;

  JumpSquatsLogic(super.targetReps) {
    feedback = "Stand tall, feet shoulder-width";
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
      feedback = "Show full legs in frame";
      return;
    }

    if (torsoOk) {
      final torsoAngle = angle(lShoulder!, lHip!, lKnee!);
      if (torsoAngle < 120) {
        feedback = "Keep chest up while squatting!";
        return;
      }
    }

    double kneeAngle;
    if (leftOk && rightOk) {
      kneeAngle = (angle(lHip!, lKnee!, lAnkle!) + angle(rHip!, rKnee!, rAnkle!)) / 2;
    } else if (leftOk) {
      kneeAngle = angle(lHip!, lKnee!, lAnkle!);
    } else {
      kneeAngle = angle(rHip!, rKnee!, rAnkle!);
    }

    if (!_isDown && kneeAngle > 165) feedback = "Squat down & explode ↓";

    if (kneeAngle < 90) {
      if (!_isDown) { _isDown = true; feedback = "Jump! ↑"; }
    }

    if (_isDown && kneeAngle > 165) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
