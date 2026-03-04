import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../exercises/base_exercise.dart';
import '../exercises/back_squat_logic.dart';
import '../exercises/bulgarian_split_squat_logic.dart';
import '../exercises/cat_stretch_logic.dart';
import '../exercises/knee_to_chest_stretch_logic.dart';
import '../exercises/pushup_logic.dart';
import '../exercises/shoulder_blade_squeeze_logic.dart';
import '../exercises/wall_sit_logic.dart';

class ExerciseEngine {
  late BaseExercise exercise;

  ExerciseEngine({required String exerciseName, required int targetReps}) {
    switch (exerciseName.toLowerCase().trim()) {
      case "pushups":
      case "push ups":
      case "push-ups":
        exercise = PushUpLogic(targetReps);
        break;

      case "back squat":
      case "back_squat":
      case "squats":
        exercise = BackSquatLogic(targetReps);
        break;

      case "bulgarian split squat":
      case "bulgarian_split_squat":
        exercise = BulgarianSplitSquatLogic(targetReps);
        break;

      case "wall sit":
      case "wall_sit":
        exercise = WallSitLogic(targetReps);
        break;

      case "cat stretch":
      case "cat_stretch":
      case "cat-cow":
        exercise = CatStretchLogic(targetReps);
        break;

      case "shoulder blade squeeze":
      case "shoulder_blade_squeeze":
        exercise = ShoulderBladeSqueezeLogic(targetReps);
        break;

      case "knee to chest":
      case "knee_to_chest":
      case "knee to chest stretch":
        exercise = KneeToChestLogic(targetReps);
        break;

      default:
        throw Exception(
          "Exercise '$exerciseName' not supported. "
          "Available: pushups, back squat, bulgarian split squat, "
          "wall sit, cat stretch, shoulder blade squeeze, knee to chest",
        );
    }
  }

  void processPose(Pose pose) {
    exercise.processPose(pose);
  }

  int get reps => exercise.reps;
  String get feedback => exercise.feedback;
  bool get isCompleted => exercise.isCompleted;
}
