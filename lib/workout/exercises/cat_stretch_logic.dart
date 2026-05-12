import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Cat Stretch: requires arching and hollowing the back.
class CatStretchLogic extends BaseExercise {
  int _state = 0; // 0=neutral, 1=arched, 2=hollowed (full rep)

  CatStretchLogic(super.targetReps) {
    feedback = "On all fours, arch and hollow your back";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (!conf([lShoulder, lHip, lKnee])) {
      feedback = "Show full side profile on all fours";
      return;
    }

    // Mid-back calculation by comparing hip to shoulder line
    final midBodyAngle = angle(lShoulder!, lHip!, lKnee!);

    // Arch (Cow): Hip angle increases (>150°)
    if (_state == 0 && midBodyAngle > 150) {
      _state = 1;
      feedback = "Now arch your back up (Cat) ↑";
    } 
    // Hollow (Cat): Hip angle decreases (<130°)
    else if (_state == 1 && midBodyAngle < 130) {
      if (countRep()) {
        _state = 0;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
