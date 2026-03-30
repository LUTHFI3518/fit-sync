import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Russian Twists: seated, torso rotates side to side.
/// Detect by tracking relative shoulder vs hip rotation.
class RussianTwistsLogic extends BaseExercise {
  int _state = 0; // 0=center, 1=right done, full rep = left done after right

  RussianTwistsLogic(super.targetReps) {
    feedback = "Sit at 45°, lean back slightly";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lHip      = pose.landmarks[PoseLandmarkType.leftHip];
    final rHip      = pose.landmarks[PoseLandmarkType.rightHip];

    if (!conf([lShoulder, rShoulder, lHip, rHip])) {
      feedback = "Show torso from front";
      return;
    }

    // Rotation is detected by the horizontal offset of shoulders relative to hips
    final shoulderMidX = (lShoulder!.x + rShoulder!.x) / 2;
    final hipMidX      = (lHip!.x + rHip!.x) / 2;
    final lShoulderX   = lShoulder.x;
    final rShoulderX   = rShoulder.x;

    // Measure shoulder spread vs hip spread to detect rotation
    final shoulderWidth = (rShoulderX - lShoulderX).abs();

    // Need significant twist: shoulder mid offset must be > 15% of shoulder width
    final isTwistedRight = (shoulderMidX - hipMidX) > shoulderWidth * 0.15;
    final isTwistedLeft  = (hipMidX - shoulderMidX) > shoulderWidth * 0.15;

    if (_state == 0) {
      if (isTwistedRight) {
        _state = 1;
        feedback = "Now twist left ←";
      } else if (isTwistedLeft) {
        _state = -1;
        feedback = "Now twist right →";
      } else {
        feedback = "Rotate further side to side";
      }
    } else if (_state == 1 && isTwistedLeft) {
      if (countRep()) { _state = 0; feedback = "Rep $reps 💪"; }
    } else if (_state == -1 && isTwistedRight) {
      if (countRep()) { _state = 0; feedback = "Rep $reps 💪"; }
    }
  }
}
