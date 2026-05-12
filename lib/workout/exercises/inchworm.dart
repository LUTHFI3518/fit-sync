import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Inchworm: requires deep hip hinge then walk-out to plank.
class InchwormLogic extends BaseExercise {
  bool _isWalkedOut = false;

  InchwormLogic(super.targetReps) {
    feedback = "Stand tall, hands at feet, walk out to plank";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    if (!conf([lShoulder, lHip, lAnkle, lWrist])) {
      feedback = "Show full side profile from floor up";
      return;
    }

    // Measure body alignment (shoulder→hip→ankle angle must be near 180° for plank)
    final bodyAngle = angle(lShoulder!, lHip!, lAnkle!);

    // Plank position: body straight (>160°) and wrist forward of shoulder
    final isPlank = bodyAngle > 160 && lWrist!.x < lShoulder.x - 50;

    if (!_isWalkedOut && isPlank) {
      _isWalkedOut = true;
      feedback = "Good plank! Now walk hands back to feet ↑";
    }

    if (_isWalkedOut && !isPlank && lWrist!.y > lHip.y) {
      // Hands returned back near feet
      if (countRep()) {
        _isWalkedOut = false;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
