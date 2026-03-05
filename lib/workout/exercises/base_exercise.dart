import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class BaseExercise {
  int reps = 0;
  int targetReps;

  String feedback = "Get ready";

  BaseExercise(this.targetReps);

  void processPose(Pose pose);

  bool get isCompleted => reps >= targetReps;
}
