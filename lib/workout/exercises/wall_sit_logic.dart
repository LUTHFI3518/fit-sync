import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

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

    final leftOk = conf([lHip, lKnee, lAnkle]);
    final rightOk = conf([rHip, rKnee, rAnkle]);

    if (!leftOk && !rightOk) {
      _holdStart = null;
      feedback = "Position yourself in frame (side view)";
      return;
    }

    double kneeAngle;
    if (leftOk && rightOk) {
      kneeAngle = (angle(lHip!, lKnee!, lAnkle!) + angle(rHip!, rKnee!, rAnkle!)) / 2;
    } else if (leftOk) {
      kneeAngle = angle(lHip!, lKnee!, lAnkle!);
    } else {
      kneeAngle = angle(rHip!, rKnee!, rAnkle!);
    }

    // Valid wall-sit position: knee between 80° and 100° (90° is perfect)
    if (kneeAngle >= 80 && kneeAngle <= 100) {
      _holdStart ??= DateTime.now();
      final elapsed = DateTime.now().difference(_holdStart!).inSeconds;

      if (elapsed != _lastReportedSeconds) {
        _lastReportedSeconds = elapsed;
        reps = elapsed;
        final remaining = targetReps - elapsed;
        if (remaining > 0) {
          feedback = "Hold! ${remaining}s to go 🔥";
        } else {
          feedback = "Done! Great wall sit! ✅";
        }
      }
    } else {
      _holdStart = null;
      _lastReportedSeconds = 0;
      if (kneeAngle < 80) {
        feedback = "Too low — rise slightly";
      } else {
        feedback = "Bend your knees more ↓";
      }
    }
  }
}
