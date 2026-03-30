import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Bicycle Crunch: alternating elbow-to-knee.
/// One full cycle (left+right) = 1 rep.
class BicycleCrunchesLogic extends BaseExercise {
  int _state = 0; // 0=neutral, 1=right-crunch done, 2=left-crunch done (full rep)

  BicycleCrunchesLogic(super.targetReps) {
    feedback = "Lie down, hands behind head";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee     = pose.landmarks[PoseLandmarkType.leftKnee];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rHip      = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee     = pose.landmarks[PoseLandmarkType.rightKnee];

    final leftOk  = conf([lShoulder, lHip, lKnee]);
    final rightOk = conf([rShoulder, rHip, rKnee]);

    if (!leftOk && !rightOk) {
      feedback = "Show full torso and knees in frame";
      return;
    }

    final lHipAngle = leftOk  ? angle(lShoulder!, lHip!, lKnee!) : 180.0;
    final rHipAngle = rightOk ? angle(rShoulder!, rHip!, rKnee!) : 180.0;

    // Require significant crunch (< 75°) on crunching side AND extension (> 130°) on other
    if (_state == 0 && rHipAngle < 75 && lHipAngle > 130) {
      _state = 1;
      feedback = "Switch — left knee to right elbow";
    } else if (_state == 1 && lHipAngle < 75 && rHipAngle > 130) {
      if (countRep()) {
        _state = 0;
        feedback = "Rep $reps 💪 Keep going!";
      }
    } else if (lHipAngle > 150 && rHipAngle > 150 && _state != 0) {
      _state = 0;
      feedback = "Keep alternating — don't stop!";
    }
  }
}
