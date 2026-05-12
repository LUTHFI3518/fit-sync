import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class BarbellCurlsHeavyLogic extends BaseExercise {
  bool _isUp = false;

  BarbellCurlsHeavyLogic(super.targetReps) {
    feedback = "Grip barbell, stand with back straight";
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
    final torsoOk = conf([lShoulder, lHip]);

    if (!leftOk && !rightOk) {
      feedback = "Show arms clearly in frame";
      return;
    }

    // No back-swing: torso must stay vertical
    if (torsoOk) {
      final backLean = lHip!.y - lShoulder!.y;
      if (backLean < 100) {
        feedback = "Stand tall — no leaning back!";
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

    if (!_isUp && elbowAngle > 155) feedback = "Curl barbell up ↑";

    if (elbowAngle < 50) {
      if (!_isUp) { _isUp = true; feedback = "Lower with control ↓"; }
    }

    if (_isUp && elbowAngle > 155) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }
  }
}
