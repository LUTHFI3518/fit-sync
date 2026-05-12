import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'base_exercise.dart';

/// Resistance Band Rows: pull elbows back, squeeze shoulder blades.
class ResistanceBandRowsLogic extends BaseExercise {
  bool _isPulled = false;

  ResistanceBandRowsLogic(super.targetReps) {
    feedback = "Hold band, arms extended forward";
  }

  @override
  void processPose(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lElbow    = pose.landmarks[PoseLandmarkType.leftElbow];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow    = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];

    if (!conf([lShoulder, lElbow, lWrist]) || !conf([rShoulder, rElbow, rWrist])) {
      feedback = "Both arms must be clearly visible";
      return;
    }

    final lA = angle(lShoulder!, lElbow!, lWrist!);
    final rA = angle(rShoulder!, rElbow!, rWrist!);
    final avgAngle = (lA + rA) / 2;

    // Extended forward: ~160°+ / Pulled back: ~70° (elbows at waist)
    if (!_isPulled && avgAngle > 155) feedback = "Row elbows back ↤";

    if (avgAngle < 75) {
      if (!_isPulled) {
        // Elbow must be behind shoulder (pulled back)
        if (lElbow.x > lShoulder.x || rElbow.x > rShoulder.x) {
          _isPulled = true;
          feedback = "Squeeze shoulder blades! Now extend ↦";
        } else {
          feedback = "Pull elbows further back!";
        }
      }
    }

    if (_isPulled && avgAngle > 155) {
      if (countRep()) { _isPulled = false; feedback = "Rep $reps 💪"; }
    }
  }
}
