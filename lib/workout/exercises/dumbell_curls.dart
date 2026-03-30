import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Dumbbell Curls: elbow must stay anchored to torso.
class DumbellCurlsLogic extends BaseExercise {
  bool _isUp = false;

  DumbellCurlsLogic(super.targetReps) {
    feedback = "Stand tall, arms at sides";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow    = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow    = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftOk  = conf([lShoulder, lElbow, lWrist]);
    final rightOk = conf([rShoulder, rElbow, rWrist]);

    if (!leftOk && !rightOk) {
      feedback = "Show arms clearly in frame";
      return;
    }

    // Elbow anchor check: elbow must NOT swing forward past shoulder
    if (leftOk && conf([lShoulder, lElbow, lHip])) {
      if (lElbow!.x < lShoulder!.x - 40) {
        feedback = "Keep elbows pinned to your sides!";
        return;
      }
    }

    double elbowAngle;
    if (leftOk && rightOk) {
      elbowAngle = (angle(lShoulder!, lElbow!, lWrist!) +
                    angle(rShoulder!, rElbow!, rWrist!)) / 2;
    } else if (leftOk) {
      elbowAngle = angle(lShoulder!, lElbow!, lWrist!);
    } else {
      elbowAngle = angle(rShoulder!, rElbow!, rWrist!);
    }

    if (!_isUp && elbowAngle > 155) feedback = "Curl up ↑";

    // Require curl to reach near full flexion
    if (elbowAngle < 50) {
      if (!_isUp) { _isUp = true; feedback = "Lower slowly ↓"; }
    }

    // Full extension at bottom
    if (_isUp && elbowAngle > 155) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }
  }
}
