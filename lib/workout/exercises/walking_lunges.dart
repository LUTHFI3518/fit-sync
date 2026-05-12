import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Walking Lunges: alternating legs, front knee must reach ~90°.
class WalkingLungesLogic extends BaseExercise {
  int _state = 0; // 0=stand, 1=left lunge, 2=right lunge

  WalkingLungesLogic(super.targetReps) {
    feedback = "Stand tall, step forward into lunge";
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
      feedback = "Show full legs in frame";
      return;
    }

    if (torsoOk) {
      final leanAngle = lHip!.y - lShoulder!.y;
      if (leanAngle < 80) {
        feedback = "Keep torso upright!";
        return;
      }
    }

    double lA = leftOk  ? angle(lHip!, lKnee!, lAnkle!) : 180.0;
    double rA = rightOk ? angle(rHip!, rKnee!, rAnkle!) : 180.0;

    // Detect lunge: front knee reaches 90°
    final leftLunge  = lA < 95;
    final rightLunge = rA < 95;
    final standing   = lA > 160 && rA > 160;

    if (_state == 0) {
      if (leftLunge)  { _state = 1; feedback = "Good! Other foot forward →"; }
      else if (rightLunge) { _state = 2; feedback = "Good! Other foot forward →"; }
      else { feedback = "Step forward and lunge deep ↓"; }
    } else if (_state == 1 && rightLunge) {
      if (countRep()) { _state = 0; feedback = "Rep $reps 💪"; }
    } else if (_state == 2 && leftLunge) {
      if (countRep()) { _state = 0; feedback = "Rep $reps 💪"; }
    } else if (standing) {
      _state = 0;
    }
  }
}
