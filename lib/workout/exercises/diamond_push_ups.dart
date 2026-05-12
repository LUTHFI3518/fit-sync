import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Diamond Push-Up: hands close together forming a diamond.
/// Detected same as push-up but requires narrower elbow clearance.
class DiamondPushUpsLogic extends BaseExercise {
  bool _isDown = false;

  DiamondPushUpsLogic(super.targetReps) {
    feedback = "Hands together forming diamond shape";
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

    final leftOk  = conf([lShoulder, lElbow, lWrist]);
    final rightOk = conf([rShoulder, rElbow, rWrist]);
    final backOk  = conf([lShoulder, lHip, lAnkle]);

    if (!leftOk && !rightOk) {
      feedback = "Full upper body must be in frame";
      return;
    }

    if (backOk) {
      final backAngle = angle(lShoulder!, lHip!, lAnkle!);
      if (backAngle < 155) {
        feedback = "Keep core tight, back straight!";
        return;
      }
    }

    // Wrists must be close together — check horizontal distance
    if (conf([lWrist, rWrist])) {
      final wristDist = (lWrist!.x - rWrist!.x).abs();
      final shoulderDist = conf([lShoulder, rShoulder])
          ? (lShoulder!.x - rShoulder!.x).abs()
          : double.infinity;
      if (wristDist > shoulderDist * 0.5) {
        feedback = "Bring hands closer — diamond grip!";
        return;
      }
    }

    double elbowAngle = 0;
    if (leftOk && rightOk) {
      elbowAngle = (angle(lShoulder!, lElbow!, lWrist!) +
                    angle(rShoulder!, rElbow!, rWrist!)) / 2;
    } else if (leftOk) {
      elbowAngle = angle(lShoulder!, lElbow!, lWrist!);
    } else {
      elbowAngle = angle(rShoulder!, rElbow!, rWrist!);
    }

    if (!_isDown && elbowAngle > 160) feedback = "Lower chest ↓";

    if (elbowAngle < 80) {
      if (!_isDown) { _isDown = true; feedback = "Push up ↑"; }
    }

    if (_isDown && elbowAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
