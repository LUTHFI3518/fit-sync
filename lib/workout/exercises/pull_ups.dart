import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

class PullUpsLogic extends BaseExercise {
  bool _isUp = false;

  PullUpsLogic(super.targetReps) {
    feedback = "Hang from bar, arms fully extended";
  }

  @override
  void processPose(Pose pose) {
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final lElbow    = pose.landmarks[PoseLandmarkType.leftElbow];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];
    final rElbow    = pose.landmarks[PoseLandmarkType.rightElbow];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (!conf([lWrist, lElbow, lShoulder]) || !conf([rWrist, rElbow, rShoulder])) {
      feedback = "Both arms must be visible on bar";
      return;
    }

    // Grip check: wrists must be above elbows (hanging from bar)
    if (lWrist!.y > lElbow!.y || rWrist!.y > rElbow!.y) {
      feedback = "Wrists must be above — grip the bar!";
      return;
    }

    final lA = angle(lWrist, lElbow, lShoulder!);
    final rA = angle(rWrist, rElbow, rShoulder!);
    final avgAngle = (lA + rA) / 2;

    // Top of pull-up: chin above bar — chin (nose landmark) must be above wrists
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final chinUp = nose != null && nose.likelihood > BaseExercise.kConf && nose.y < lWrist.y;

    if (!_isUp && chinUp) {
      _isUp = true;
      feedback = "Lower fully — arms straight ↓";
    }

    // Bottom: arms fully extended (close to 180°)
    if (_isUp && avgAngle > 160) {
      if (countRep()) { _isUp = false; feedback = "Rep $reps 💪"; }
    }

    if (!_isUp && !chinUp) {
      feedback = "Pull yourself up — chin over bar ↑";
    }
  }
}
