import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Wall Sit — isometric hold measured in seconds.
/// The knee angle (hip→knee→ankle) must stay between 80°–100° (roughly 90°).
/// `reps` counts elapsed hold seconds; `targetReps` = target seconds.
class WallSitLogic extends BaseExercise {
  DateTime? _holdStart;
  int _lastReportedSeconds = 0;

  WallSitLogic(super.seconds) {
    feedback = "Stand with back against wall, feet out";
  }

  @override
  void processPose(Pose pose) {
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final leftOk = _conf(lHip, lKnee, lAnkle);
    final rightOk = _conf(rHip, rKnee, rAnkle);

    if (!leftOk && !rightOk) {
      _holdStart = null;
      feedback = "Position yourself in frame";
      return;
    }

    double angle;
    if (leftOk && rightOk) {
      angle = (_dot(lHip!, lKnee!, lAnkle!) + _dot(rHip!, rKnee!, rAnkle!)) / 2;
    } else if (leftOk) {
      angle = _dot(lHip!, lKnee!, lAnkle!);
    } else {
      angle = _dot(rHip!, rKnee!, rAnkle!);
    }

    // Valid wall-sit position: knee between 75° and 105°
    if (angle >= 75 && angle <= 105) {
      _holdStart ??= DateTime.now();
      final elapsed = DateTime.now().difference(_holdStart!).inSeconds;

      if (elapsed != _lastReportedSeconds) {
        _lastReportedSeconds = elapsed;
        reps = elapsed;
        final remaining = targetReps - elapsed;
        if (remaining > 0) {
          feedback = "Hold! ${remaining}s to go \ud83d\udd25";
        } else {
          feedback = "Done! Great wall sit! \u2705";
        }
      }
    } else {
      _holdStart = null;
      _lastReportedSeconds = 0;
      if (angle < 75) {
        feedback = "Too low — rise slightly";
      } else {
        feedback = "Bend knees more \u2193";
      }
    }
  }

  bool _conf(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) =>
      a != null &&
      b != null &&
      c != null &&
      a.likelihood > 0.5 &&
      b.likelihood > 0.5 &&
      c.likelihood > 0.5;

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
