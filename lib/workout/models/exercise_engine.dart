import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../exercises/base_exercise.dart';
import '../exercises/back_squat_logic.dart';
import '../exercises/bulgarian_split_squat_logic.dart';
import '../exercises/cat_stretch_logic.dart';
import '../exercises/knee_to_chest_stretch_logic.dart';
import '../exercises/pushup_logic.dart';
import '../exercises/shoulder_blade_squeeze_logic.dart';
import '../exercises/wall_sit_logic.dart';

import '../exercises/bicycle_crunches.dart';
import '../exercises/decline_pushups.dart';
import '../exercises/dumbell_curls.dart';
import '../exercises/dumbell_side_rise.dart';
import '../exercises/handstand_push_ups.dart';
import '../exercises/inchworm.dart';
import '../exercises/incline_pushups.dart';
import '../exercises/leg_rises.dart';
import '../exercises/pike_pushups.dart';
import '../exercises/side_plank.dart';
import '../exercises/ticeps_dips.dart';
import '../exercises/diamond_push_ups.dart';
import '../exercises/archer_push_ups.dart';
import '../exercises/close_grip_push_ups.dart';
import '../exercises/clap_push_ups.dart';
import '../exercises/one_arm_push_ups.dart';
import '../exercises/weighted_push_ups.dart';
import '../exercises/walking_lunges.dart';
import '../exercises/step_ups.dart';
import '../exercises/jump_squats.dart';
import '../exercises/pistol_squats.dart';
import '../exercises/barbell_squats_heavy.dart';
import '../exercises/bulgarian_split_squat_weighted.dart';
import '../exercises/hammer_curls.dart';
import '../exercises/barbell_curls_heavy.dart';
import '../exercises/one_arm_tricep_dips.dart';
import '../exercises/ring_dips.dart';
import '../exercises/resistance_band_rows.dart';
import '../exercises/pull_ups.dart';
import '../exercises/superman_pulls.dart';
import '../exercises/deadlifts.dart';
import '../exercises/overhead_tricep_extension.dart';
import '../exercises/arnold_press.dart';
import '../exercises/dumbbell_front_raise.dart';
import '../exercises/dumbbell_bench_press.dart';
import '../exercises/barbell_overhead_press.dart';
import '../exercises/pike_push_ups_elevated.dart';
import '../exercises/pike_push_ups_decline.dart';
import '../exercises/handstand_push_ups_free.dart';
import '../exercises/hanging_knee_raises.dart';
import '../exercises/hanging_leg_raises.dart';
import '../exercises/toes_to_bar.dart';
import '../exercises/russian_twists.dart';
import '../exercises/superman_hold.dart';
import '../exercises/reverse_snow_angels.dart';
import '../exercises/dragon_flag.dart';
import '../exercises/plank_shoulder_taps.dart';

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

      case "bicycle crunches":
      case "bicycle_crunches":
        exercise = BicycleCrunchesLogic(targetReps);
        break;

      case "decline pushups":
      case "decline push ups":
      case "decline_pushups":
        exercise = DeclinePushupsLogic(targetReps);
        break;

      case "dumbell curls":
      case "dumbbell curls":
      case "dumbell_curls":
        exercise = DumbellCurlsLogic(targetReps);
        break;

      case "dumbell side rise":
      case "dumbbell lateral raise":
      case "lateral raises":
      case "dumbell_side_rise":
        exercise = DumbellSideRiseLogic(targetReps);
        break;

      case "handstand push ups":
      case "handstand pushups":
      case "handstand_push_ups":
        exercise = HandstandPushUpsLogic(targetReps);
        break;

      case "inchworm":
      case "inchworms":
        exercise = InchwormLogic(targetReps);
        break;

      case "incline pushups":
      case "incline push ups":
      case "incline_pushups":
        exercise = InclinePushupsLogic(targetReps);
        break;

      case "leg rises":
      case "leg raises":
      case "leg_rises":
        exercise = LegRisesLogic(targetReps);
        break;

      case "pike pushups":
      case "pike push ups":
      case "pike_pushups":
        exercise = PikePushupsLogic(targetReps);
        break;

      case "side plank":
      case "side_plank":
        exercise = SidePlankLogic(targetReps);
        break;

      case "ticeps_dips":
        exercise = TicepsDipsLogic(targetReps);
        break;

      case "diamond push-ups":
      case "diamond_push_ups":
        exercise = DiamondPushUpsLogic(targetReps);
        break;
      case "archer push-ups":
      case "archer_push_ups":
        exercise = ArcherPushUpsLogic(targetReps);
        break;
      case "close grip push-ups":
      case "close_grip_push_ups":
        exercise = CloseGripPushUpsLogic(targetReps);
        break;
      case "clap push-ups":
      case "clap_push_ups":
        exercise = ClapPushUpsLogic(targetReps);
        break;
      case "one-arm push-ups":
      case "one_arm_push_ups":
        exercise = OneArmPushUpsLogic(targetReps);
        break;
      case "weighted push-ups":
      case "weighted_push_ups":
        exercise = WeightedPushUpsLogic(targetReps);
        break;
      case "walking lunges":
      case "walking_lunges":
        exercise = WalkingLungesLogic(targetReps);
        break;
      case "step-ups":
      case "step_ups":
        exercise = StepUpsLogic(targetReps);
        break;
      case "jump squats":
      case "jump_squats":
        exercise = JumpSquatsLogic(targetReps);
        break;
      case "pistol squats":
      case "pistol_squats":
        exercise = PistolSquatsLogic(targetReps);
        break;
      case "barbell squats heavy":
      case "barbell_squats_heavy":
        exercise = BarbellSquatsHeavyLogic(targetReps);
        break;
      case "bulgarian split squat weighted":
      case "bulgarian_split_squat_weighted":
        exercise = BulgarianSplitSquatWeightedLogic(targetReps);
        break;
      case "hammer curls":
      case "hammer_curls":
        exercise = HammerCurlsLogic(targetReps);
        break;
      case "barbell curls heavy":
      case "barbell_curls_heavy":
        exercise = BarbellCurlsHeavyLogic(targetReps);
        break;
      case "one-arm tricep dips":
      case "one_arm_tricep_dips":
        exercise = OneArmTricepDipsLogic(targetReps);
        break;
      case "ring dips":
      case "ring_dips":
        exercise = RingDipsLogic(targetReps);
        break;
      case "resistance band rows":
      case "resistance_band_rows":
        exercise = ResistanceBandRowsLogic(targetReps);
        break;
      case "pull-ups":
      case "pull_ups":
        exercise = PullUpsLogic(targetReps);
        break;
      case "superman pulls":
      case "superman_pulls":
        exercise = SupermanPullsLogic(targetReps);
        break;
      case "deadlifts":
      case "deadlift":
        exercise = DeadliftsLogic(targetReps);
        break;
      case "overhead tricep extension":
      case "overhead_tricep_extension":
        exercise = OverheadTricepExtensionLogic(targetReps);
        break;
      case "arnold press":
      case "arnold_press":
        exercise = ArnoldPressLogic(targetReps);
        break;
      case "dumbbell front raise":
      case "dumbbell_front_raise":
        exercise = DumbbellFrontRaiseLogic(targetReps);
        break;
      case "dumbbell bench press":
      case "dumbbell_bench_press":
        exercise = DumbbellBenchPressLogic(targetReps);
        break;
      case "barbell overhead press":
      case "barbell_overhead_press":
        exercise = BarbellOverheadPressLogic(targetReps);
        break;
      case "pike push-ups elevated":
      case "pike_push_ups_elevated":
        exercise = PikePushUpsElevatedLogic(targetReps);
        break;
      case "pike push-ups decline":
      case "pike_push_ups_decline":
        exercise = PikePushUpsDeclineLogic(targetReps);
        break;
      case "handstand push-ups free":
      case "handstand_push_ups_free":
        exercise = HandstandPushUpsFreeLogic(targetReps);
        break;
      case "hanging knee raises":
      case "hanging_knee_raises":
        exercise = HangingKneeRaisesLogic(targetReps);
        break;
      case "hanging leg raises":
      case "hanging_leg_raises":
        exercise = HangingLegRaisesLogic(targetReps);
        break;
      case "toes to bar":
      case "toes_to_bar":
        exercise = ToesToBarLogic(targetReps);
        break;
      case "russian twists":
      case "russian_twists":
        exercise = RussianTwistsLogic(targetReps);
        break;
      case "superman hold":
      case "superman_hold":
        exercise = SupermanHoldLogic(targetReps);
        break;
      case "reverse snow angels":
      case "reverse_snow_angels":
        exercise = ReverseSnowAngelsLogic(targetReps);
        break;
      case "dragon flag":
      case "dragon_flag":
        exercise = DragonFlagLogic(targetReps);
        break;
      case "plank shoulder taps":
      case "plank_shoulder_taps":
        exercise = PlankShoulderTapsLogic(targetReps);
        break;

      default:
        throw Exception(
          "Exercise '$exerciseName' not supported.",
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
