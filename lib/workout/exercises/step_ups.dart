import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class StepUpsLogic extends BaseExercise {
  bool _isUp = false;

  StepUpsLogic(super.targetReps) {
    feedback = "Step up onto box or chair";
  }

  @override
  void processPose(Pose pose) {
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final leftOk = conf([lHip, lKnee, lAnkle]);
    final rightOk = conf([rHip, rKnee, rAnkle]);
    final torsoOk = conf([lShoulder, lHip]);

    if (!leftOk && !rightOk) {
      feedback = "Show full side profile and legs";
      return;
    }

    if (torsoOk && (lHip!.y - lShoulder!.y) < 80) {
      feedback = "Keep torso upright!";
      return;
    }

    // Measure knee height relative to hip
    // Up: at least one knee is at or above hip level (meaning you stepped up)
    final lUp = leftOk && lKnee!.y <= lHip!.y + 20;
    final rUp = rightOk && rKnee!.y <= rHip!.y + 20;

    if (!_isUp && (lUp || rUp)) {
      _isUp = true;
      feedback = "Now step down ↓";
    }

    if (_isUp && !lUp && !rUp) {
      if (countRep()) {
        _isUp = false;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
