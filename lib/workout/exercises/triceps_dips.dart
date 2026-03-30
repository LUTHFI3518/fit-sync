import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class TicepsDipsLogic extends BaseExercise {
  bool _isDown = false;

  TicepsDipsLogic(super.targetReps) {
    feedback = "Hands behind on surface, arms straight";
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
      feedback = "Show both arms clearly in frame";
      return;
    }

    // Shoulders must stay near or below wrist level (not shrugged up)
    if (conf([lShoulder, lWrist]) && lShoulder!.y < lWrist!.y - 60) {
      feedback = "Keep shoulders down, don't shrug!";
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

    if (!_isDown && elbowAngle > 155) feedback = "Dip down ↓";

    if (elbowAngle < 80) {
      if (!_isDown) { _isDown = true; feedback = "Push back up ↑"; }
    }

    if (_isDown && elbowAngle > 155) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
