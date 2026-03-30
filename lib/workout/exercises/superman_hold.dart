import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Superman Hold: isometric hold with body lifted, counted in seconds.
class SupermanHoldLogic extends BaseExercise {
  DateTime? _holdStart;
  int _lastReported = 0;

  SupermanHoldLogic(super.seconds) {
    feedback = "Lie face down, arms and legs extended";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle    = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (!conf([lShoulder, lWrist, lHip, lAnkle])) {
      _holdStart = null;
      feedback = "Show full side profile";
      return;
    }

    // Must have wrists AND ankles above hip (full superman position)
    final inPosition = lWrist!.y < lHip!.y && lAnkle!.y < lHip.y;

    if (inPosition) {
      _holdStart ??= DateTime.now();
      final elapsed = DateTime.now().difference(_holdStart!).inSeconds;
      if (elapsed != _lastReported) {
        _lastReported = elapsed;
        reps = elapsed;
        final remaining = targetReps - elapsed;
        feedback = remaining > 0 ? "Hold! ${remaining}s to go 🔥" : "Done! Perfect hold ✅";
      }
    } else {
      _holdStart = null;
      _lastReported = 0;
      feedback = "Lift arms AND legs — hold the position!";
    }
  }
}
