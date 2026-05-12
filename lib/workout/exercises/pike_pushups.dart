import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class PikePushupsLogic extends BaseExercise {
  bool _isDown = false;

  PikePushupsLogic(super.targetReps) {
    feedback = "Hips high, hands and feet on floor";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWr = pose.landmarks[PoseLandmarkType.leftWrist];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWr = pose.landmarks[PoseLandmarkType.rightWrist];

    if (!conf([lShoulder, lElbow, lWr]) && !conf([rShoulder, rElbow, rWr])) {
      feedback = "Show shoulders and elbows clearly";
      return;
    }

    double elbowAngle;
    if (lElbow != null && lWr != null && lShoulder != null) {
      elbowAngle = angle(lShoulder, lElbow, lWr);
    } else {
      elbowAngle = angle(rShoulder!, rElbow!, rWr!);
    }

    if (!_isDown && elbowAngle > 155) feedback = "Lower head to floor ↓";

    if (elbowAngle < 85) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Push up ↑";
      }
    }

    if (_isDown && elbowAngle > 155) {
      if (countRep()) {
        _isDown = false;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
