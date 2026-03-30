import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class ArcherPushUpsLogic extends BaseExercise {
  bool _isDown = false;

  ArcherPushUpsLogic(super.targetReps) {
    feedback = "Wide arms, one arm leads each rep";
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
        feedback = "Keep back straight!";
        return;
      }
    }

    // For archer, track the primary (bent) arm angle — whichever is lower
    double lAngle = leftOk ? angle(lShoulder!, lElbow!, lWrist!) : 180.0;
    double rAngle = rightOk ? angle(rShoulder!, rElbow!, rWrist!) : 180.0;
    double minAngle = lAngle < rAngle ? lAngle : rAngle;

    if (!_isDown && minAngle > 160) feedback = "Bend one arm to the side ↓";

    if (minAngle < 80) {
      if (!_isDown) { _isDown = true; feedback = "Push up ↑"; }
    }

    if (_isDown && minAngle > 160) {
      if (countRep()) { _isDown = false; feedback = "Rep $reps 💪"; }
    }
  }
}
