import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Plank Shoulder Taps: alternating hand-to-opposite-shoulder taps.
/// Full cycle (left+right) = 1 rep.
class PlankShoulderTapsLogic extends BaseExercise {
  int _state = 0; // 0=neutral, 1=right tap, 2=left tap (full rep)

  PlankShoulderTapsLogic(super.targetReps) {
    feedback = "Plank position, core tight, tap shoulders";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lWr       = pose.landmarks[PoseLandmarkType.leftWrist];
    final rWr       = pose.landmarks[PoseLandmarkType.rightWrist];

    if (!conf([lShoulder, rShoulder, lWr, rWr])) {
      feedback = "Show full upper body plank position";
      return;
    }

    // Tap detected: wrist Y reaches shoulder Y level
    final lTap = lWr!.y <= rShoulder!.y + 30;
    final rTap = rWr!.y <= lShoulder!.y + 30;

    if (_state == 0 && rTap) {
      _state = 1;
      feedback = "Switch — tap left shoulder ←";
    } else if (_state == 1 && lTap) {
      if (countRep()) {
        _state = 0;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
