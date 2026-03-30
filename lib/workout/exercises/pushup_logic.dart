import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class PushUpLogic extends BaseExercise {
  bool _isDown = false;

  PushUpLogic(super.targetReps) {
    feedback = "Get into pushup position";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow    = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final lAnkle    = pose.landmarks[PoseLandmarkType.leftAnkle];

    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow    = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftArmOk  = conf([lShoulder, lElbow, lWrist]);
    final rightArmOk = conf([rShoulder, rElbow, rWrist]);
    final backOk     = conf([lShoulder, lHip, lAnkle]);

    if (!leftArmOk && !rightArmOk) {
      feedback = "Show your full upper body in frame";
      return;
    }

    // 1. Back-straightness check — must be straight, not sagging/piking
    if (backOk) {
      final backAngle = angle(lShoulder!, lHip!, lAnkle!);
      if (backAngle < 155) {
        feedback = "Keep your back straight!";
        return;
      }
    }

    // 2. Compute elbow angle
    double elbowAngle = 0;
    if (leftArmOk && rightArmOk) {
      elbowAngle = (angle(lShoulder!, lElbow!, lWrist!) +
                    angle(rShoulder!, rElbow!, rWrist!)) / 2;
    } else if (leftArmOk) {
      elbowAngle = angle(lShoulder!, lElbow!, lWrist!);
    } else {
      elbowAngle = angle(rShoulder!, rElbow!, rWrist!);
    }

    // 3. State machine with strict thresholds
    if (!_isDown && elbowAngle > 160) {
      feedback = "Go down ↓";
    }

    if (elbowAngle < 80) {
      if (!_isDown) {
        _isDown = true;
        feedback = "Push up ↑";
      }
    }

    if (_isDown && elbowAngle > 160) {
      if (countRep()) {
        _isDown = false;
        feedback = "Great! Rep $reps 💪";
      }
    }
  }
}
