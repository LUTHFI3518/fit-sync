import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Shoulder Blade Squeeze — measures the angle between arms and torso.
/// Uses the elbow angle (shoulder→elbow→wrist) on both sides as a proxy:
/// when elbows are bent and pulled back (retraction),
/// shoulder→elbow distance narrows relative to torso width.
///
/// Detection strategy:
///   - Shoulder width ratio: distance(lShoulder, rShoulder) normalized against
///     hip width gives a retraction score.
///   - Squeeze = shoulders pulled back → shoulder-to-shoulder distance decreases,
///     elbow angles go between 70°–110° (elbows bent, pulled behind torso).
class ShoulderBladeSqueezeLogic extends BaseExercise {
  bool _isSqueezed = false;
  DateTime? _squeezeStart;
  static const _holdMs = 1500; // hold 1.5s to confirm a squeeze rep

  ShoulderBladeSqueezeLogic(super.targetReps) {
    feedback = "Stand tall, arms relaxed at sides";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (lShoulder == null ||
        rShoulder == null ||
        lElbow == null ||
        rElbow == null ||
        lWrist == null ||
        rWrist == null ||
        lHip == null ||
        rHip == null) {
      feedback = "Face the camera, arms visible";
      return;
    }

    if (lShoulder.likelihood < 0.5 ||
        rShoulder.likelihood < 0.5 ||
        lElbow.likelihood < 0.5 ||
        rElbow.likelihood < 0.5) {
      feedback = "Hold still, detecting...";
      return;
    }

    // Elbow angle on both arms (shoulder→elbow→wrist)
    final lAngle = _dot(lShoulder, lElbow, lWrist);
    final rAngle = _dot(rShoulder, rElbow, rWrist);

    // Shoulder-to-shoulder distance normalized by hip width
    final shoulderDist = _dist(lShoulder, rShoulder);
    final hipDist = _dist(lHip, rHip);
    // When squeezing, elbows bend and pull back — shoulder width decreases vs hips
    final ratio = shoulderDist / hipDist;

    // Squeeze detected: elbows bent 60–120°, shoulders narrower than hips (ratio < 1.05)
    final inSqueezePosition =
        lAngle > 60 &&
        lAngle < 120 &&
        rAngle > 60 &&
        rAngle < 120 &&
        ratio < 1.1;

    if (inSqueezePosition) {
      if (!_isSqueezed) {
        _isSqueezed = true;
        _squeezeStart = DateTime.now();
        feedback = "Squeeze and hold!";
      } else {
        final held = DateTime.now().difference(_squeezeStart!).inMilliseconds;
        if (held >= _holdMs) {
          reps++;
          _isSqueezed = false;
          _squeezeStart = null;
          feedback = "Rep $reps! Relax shoulders";
        } else {
          feedback = "Squeeze harder! Hold...";
        }
      }
    } else {
      _isSqueezed = false;
      _squeezeStart = null;
      feedback = "Pull elbows back, squeeze blades \ud83d\udd19";
    }
  }

  double _dist(PoseLandmark a, PoseLandmark b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
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
