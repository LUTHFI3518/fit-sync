import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Knee-to-Chest Stretch — timed hold exercise.
/// Detects when the knee rises toward the chest by measuring
/// the angle at the hip (shoulder→hip→knee).
/// A tight knee-to-chest position = hip angle < 60°.
/// Hold for 3 seconds to count one rep (one stretch = each side alternating,
/// but with a front camera we track whichever knee is more visible).
class KneeToChestLogic extends BaseExercise {
  DateTime? _holdStart;
  bool _inPosition = false;
  static const _holdThresholdMs = 3000; // 3-second hold per rep

  KneeToChestLogic(super.targetReps) {
    feedback = "Lie on your back, pull knee to chest";
  }

  @override
  void processPose(Pose pose) {
    // Try left side first, fall back to right
    PoseLandmark? shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? hip = pose.landmarks[PoseLandmarkType.leftHip];
    PoseLandmark? knee = pose.landmarks[PoseLandmarkType.leftKnee];

    final leftOk =
        shoulder != null &&
        hip != null &&
        knee != null &&
        shoulder.likelihood > 0.45 &&
        hip.likelihood > 0.45 &&
        knee.likelihood > 0.45;

    if (!leftOk) {
      shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      hip = pose.landmarks[PoseLandmarkType.rightHip];
      knee = pose.landmarks[PoseLandmarkType.rightKnee];
    }

    if (shoulder == null ||
        hip == null ||
        knee == null ||
        shoulder.likelihood < 0.45 ||
        hip.likelihood < 0.45 ||
        knee.likelihood < 0.45) {
      feedback = "Lie down, face camera from the side";
      _holdStart = null;
      _inPosition = false;
      return;
    }

    // Hip angle — smaller = knee closer to chest
    final hipAngle = _dot(shoulder, hip, knee);

    if (hipAngle < 60) {
      // Knee is close to chest
      if (!_inPosition) {
        _inPosition = true;
        _holdStart = DateTime.now();
        feedback = "Great! Hold it...";
      } else {
        final held = DateTime.now().difference(_holdStart!).inMilliseconds;
        final remaining = ((_holdThresholdMs - held) / 1000).ceil();
        if (remaining > 0) {
          feedback = "Hold... ${remaining}s";
        } else {
          reps++;
          _inPosition = false;
          _holdStart = null;
          feedback = "Rep $reps! Switch legs";
        }
      }
    } else {
      _inPosition = false;
      _holdStart = null;
      if (hipAngle < 100) {
        feedback = "Pull knee closer to chest";
      } else {
        feedback = "Lift knee toward your chest \u2191";
      }
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
