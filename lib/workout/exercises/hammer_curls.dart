import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class HammerCurlsLogic extends BaseExercise {
  bool _isUp = false;

  HammerCurlsLogic(super.targetReps) {
    feedback = "Palms facing in, arms at sides";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow    = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow    = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftOk  = conf([lShoulder, lElbow, lWrist]);
    final rightOk = conf([rShoulder, rElbow, rWrist]);

    if (!leftOk && !rightOk) {
      feedback = "Show arms clearly in frame";
      return;
    }

    // Elbow swing check
    if (leftOk && lElbow!.x < lShoulder!.x - 40) {
      feedback = "Keep elbows at your sides!";
      return;
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

    if (!_isUp && elbowAngle > 155) feedback = "Hammer curl up ↑";

    if (elbowAngle < 50) {
      if (!_isUp) { _isUp = true; feedback = "Lower slowly ↓"; }
    }

    if (_isUp && elbowAngle > 155) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }
  }
}
