import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class PikePushUpsDeclineLogic extends BaseExercise {
  bool _isDown = false;

  PikePushUpsDeclineLogic(super.targetReps) {
    feedback = "Feet on floor, hands on surface, hips high ↓";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWr = pose.landmarks[PoseLandmarkType.leftWrist];

    if (!conf([lShoulder, lElbow, lWr])) {
      feedback = "Show shoulder and elbow clearly";
      return;
    }

    final elbowAngle = angle(lShoulder!, lElbow!, lWr!);

    if (!_isDown && elbowAngle > 155) feedback = "Lower head controlled ↓";

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
