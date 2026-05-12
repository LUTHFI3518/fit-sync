import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Shoulder Blade Squeeze: pull elbows back, squeeze scapula.
class ShoulderBladeSqueezeLogic extends BaseExercise {
  bool _isSqueezed = false;

  ShoulderBladeSqueezeLogic(super.targetReps) {
    feedback = "Stand tall, arms at sides, elbows bent 90°";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];

    if (!conf([lShoulder, lElbow, rShoulder, rElbow])) {
      feedback = "Show both shoulders and elbows (front view)";
      return;
    }

    // Squeeze: elbows move behind shoulder plane
    // Offset check: horizontal distance of elbows relative to shoulders
    final lOffset = lShoulder!.x - lElbow!.x;
    final rOffset = rElbow!.x - rShoulder!.x;

    if (!_isSqueezed && lOffset < -20 && rOffset < -20) {
      _isSqueezed = true;
      feedback = "Hold! Now release forward ➔";
    }

    if (_isSqueezed && lOffset > 20 && rOffset > 20) {
      if (countRep()) {
        _isSqueezed = false;
        feedback = "Rep $reps 💪";
      }
    }
  }
}
