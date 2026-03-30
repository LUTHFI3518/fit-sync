import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Reverse Snow Angels: prone-lift, arms sweep from sides to overhead.
class ReverseSnowAngelsLogic extends BaseExercise {
  bool _isLifted = false;

  ReverseSnowAngelsLogic(super.targetReps) {
    feedback = "Lie face down, arms at sides, palms up";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];

    if (!conf([lShoulder, lWrist, lHip])) {
      feedback = "Show full upper body lying flat";
      return;
    }

    // Prone lift: wrist Y reaches shoulder Y level
    final isLifted = lWrist!.y <= lShoulder!.y + 30;

    // Side-to-overhead sweep: wrist X relative to shoulder X
    final isOverhead = lWrist.x < lShoulder.x - 40;

    if (!_isLifted && isLifted && isOverhead) {
      _isLifted = true;
      feedback = "Good lift! Now sweep back to hips ↓";
    }

    if (_isLifted && lWrist.x > lHip!.x + 20) {
      if (countRep()) {
        _isLifted = false;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
