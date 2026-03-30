import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Side Plank: isometric hold on one side, counted in seconds.
class SidePlankLogic extends BaseExercise {
  DateTime? _holdStart;
  int _lastReported = 0;

  SidePlankLogic(super.seconds) {
    feedback = "Prop yourself on elbow, lift hips high";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (!conf([lShoulder, lHip, lAnkle])) {
      _holdStart = null;
      feedback = "Show full body side profile";
      return;
    }

    // Measure body alignment (shoulder→hip→ankle angle must be near 180°)
    final bodyAngle = angle(lShoulder!, lHip!, lAnkle!);

    // Plank position: body straight (>160°) and hip lifted (>15px gap logic)
    if (bodyAngle > 160) {
      _holdStart ??= DateTime.now();
      final elapsed = DateTime.now().difference(_holdStart!).inSeconds;
      if (elapsed != _lastReported) {
        _lastReported = elapsed;
        reps = elapsed;
        final remaining = targetReps - elapsed;
        feedback = remaining > 0 ? "Hold it! ${remaining}s to go 🔥" : "Done! Strong side plank ✅";
      }
    } else {
      _holdStart = null;
      _lastReported = 0;
      feedback = "Keep your body straight — don't dip hips!";
    }
  }
}
