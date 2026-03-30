import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Toes to Bar: hanging, toes must reach wrist level.
class ToesToBarLogic extends BaseExercise {
  bool _isUp = false;

  ToesToBarLogic(super.targetReps) {
    feedback = "Hang from bar, legs straight";
  }

  @override
  void processPose(Pose pose) {
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle    = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (!conf([lWrist, lShoulder, lHip, lAnkle])) {
      feedback = "Show full body in frame";
      return;
    }

    // Grip check
    if (lWrist!.y > lShoulder!.y) {
      feedback = "Hands above — hang from bar!";
      return;
    }

    // Toes-to-bar: ankle Y must reach wrist Y level (both near top of frame)
    final ankleNearBar = lAnkle!.y <= lWrist.y + 40; // within 40px below wrist

    if (!_isUp && ankleNearBar) {
      _isUp = true;
      feedback = "Lower legs slowly ↓";
    }

    if (_isUp && lAnkle.y > lHip!.y + 80) {
      // Legs lowered back below hip
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp && !ankleNearBar) {
      feedback = "Kick toes up to the bar ↑";
    }
  }
}
