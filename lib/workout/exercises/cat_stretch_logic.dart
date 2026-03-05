import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Cat Stretch (Cat-Cow) — timed hold exercise.
/// Detects spinal flexion by measuring the angle at the mid-spine
/// (left shoulder → left hip → left knee as a proxy for trunk curve).
/// Hold the arched position for 2+ seconds per rep.
class CatStretchLogic extends BaseExercise {
  DateTime? _holdStart;
  bool _inPosition = false;
  static const _holdThresholdMs = 2000; // hold for 2s to count a rep

  CatStretchLogic(super.targetReps) {
    feedback = "Get on hands and knees";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (lShoulder == null ||
        lHip == null ||
        lKnee == null ||
        lShoulder.likelihood < 0.5 ||
        lHip.likelihood < 0.5 ||
        lKnee.likelihood < 0.5) {
      feedback = "Get on all fours, face the camera sideways";
      _holdStart = null;
      return;
    }

    // Trunk angle: shoulder→hip→knee
    // A rounded back brings the shoulder and knee closer (angle decreases toward ~90-120°)
    // An arched back extends this angle toward ~150-170°
    final trunkAngle = _dot(lShoulder, lHip, lKnee);

    // Cat pose = back rounds → angle < 130°
    if (trunkAngle < 130) {
      if (!_inPosition) {
        _inPosition = true;
        _holdStart = DateTime.now();
        feedback = "Good arch! Hold it...";
      } else {
        final held = DateTime.now().difference(_holdStart!).inMilliseconds;
        final remaining = ((_holdThresholdMs - held) / 1000).ceil();
        if (remaining > 0) {
          feedback = "Hold... ${remaining}s";
        } else {
          reps++;
          _inPosition = false;
          _holdStart = null;
          feedback = "Rep $reps! Now release \u2193";
        }
      }
    } else {
      _inPosition = false;
      _holdStart = null;
      feedback = "Round your back more \ud83d\udc08";
    }
  }

  double _dot(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final v1x = a.x - b.x;
    final v1y = a.y - b.y;
    final v2x = c.x - b.x;
    final v2y = c.y - b.y;
    final dot = v1x * v2x + v1y * v2y;
    final mag1 = sqrt(v1x * v1x + v1y * v1y);
    final mag2 = sqrt(v2x * v2x + v2y * v2y);
    if (mag1 == 0 || mag2 == 0) return 180;
    return acos((dot / (mag1 * mag2)).clamp(-1.0, 1.0)) * 180 / pi;
  }
}
