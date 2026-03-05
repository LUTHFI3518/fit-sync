import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:provider/provider.dart';
import '../../controllers/workout_controller.dart';
import '../models/exercise_engine.dart';
import '../pose_detection/pose_detector_service.dart';
import 'pose_painter.dart';

class WorkoutCameraPage extends StatefulWidget {
  /// Full exercise document from the backend (contains $id, name, targetReps, avgRepSeconds, etc.)
  final Map<String, dynamic> exercise;

  const WorkoutCameraPage({super.key, required this.exercise});

  @override
  State<WorkoutCameraPage> createState() => _WorkoutCameraPageState();
}

class _WorkoutCameraPageState extends State<WorkoutCameraPage> {
  CameraController? _cameraController;
  late PoseDetectorService _poseService;
  late ExerciseEngine _engine;

  bool _isProcessing = false;
  int _reps = 0;
  Pose? _currentPose;
  Size _imageSize = Size.zero;
  String _feedback = "Get ready";
  DateTime? _lastDetectionTime;

  /// Resolved exercise properties
  late final String _exerciseId;
  late final String _exerciseName;
  late final int _targetReps; // 0 means it is a timed exercise
  late final int _avgRepSeconds; // used as duration target for timed exercises

  @override
  void initState() {
    super.initState();

    _exerciseId = widget.exercise['\$id'] ?? '';
    _exerciseName = widget.exercise['name'] ?? '';

    // targetReps == 0 → timed exercise; use avgRepSeconds as the goal duration
    final rawReps = widget.exercise['targetReps'];
    _targetReps = (rawReps is int) ? rawReps : int.tryParse('$rawReps') ?? 0;

    final rawAvg = widget.exercise['avgRepSeconds'];
    _avgRepSeconds = (rawAvg is int) ? rawAvg : int.tryParse('$rawAvg') ?? 30;

    // For timed exercises pass avgRepSeconds as "target" to the engine
    final engineTarget = _targetReps == 0 ? _avgRepSeconds : _targetReps;

    _poseService = PoseDetectorService();
    _engine = ExerciseEngine(
      exerciseName: _exerciseName,
      targetReps: engineTarget,
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processCameraImage);

    if (mounted) setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final now = DateTime.now();
    if (_lastDetectionTime != null &&
        now.difference(_lastDetectionTime!).inMilliseconds < 120) {
      return;
    }
    if (_isProcessing) return;

    _lastDetectionTime = now;
    _isProcessing = true;

    try {
      final inputImage = _buildInputImage(image);
      final imgSize = Size(image.width.toDouble(), image.height.toDouble());

      final poses = await _poseService.detectPose(inputImage);

      if (!mounted) return;

      if (poses.isNotEmpty) {
        _engine.processPose(poses.first);

        setState(() {
          _currentPose = poses.first;
          _imageSize = imgSize;
          _reps = _engine.reps;
          _feedback = _engine.feedback;
        });

        if (_engine.isCompleted) {
          _finishWorkout();
        }
      }
    } catch (e) {
      debugPrint("Pose detection error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  InputImage _buildInputImage(CameraImage image) {
    final camera = _cameraController!.description;

    final bytes = Uint8List.fromList(
      image.planes.fold<List<int>>(
        [],
        (buf, plane) => buf..addAll(plane.bytes),
      ),
    );

    InputImageRotation rotation;
    final orientation = camera.sensorOrientation;

    if (camera.lensDirection == CameraLensDirection.front) {
      switch (orientation) {
        case 90:
          rotation = InputImageRotation.rotation270deg;
          break;
        case 270:
          rotation = InputImageRotation.rotation90deg;
          break;
        case 180:
          rotation = InputImageRotation.rotation180deg;
          break;
        default:
          rotation = InputImageRotation.rotation0deg;
      }
    } else {
      rotation =
          InputImageRotationValue.fromRawValue(orientation) ??
          InputImageRotation.rotation0deg;
    }

    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> _finishWorkout() async {
    // Stop camera first to avoid further processing
    await _cameraController?.stopImageStream();

    if (!mounted) return;

    // Report completion to backend
    final ctrl = context.read<WorkoutController>();
    final allDone = await ctrl.markExerciseDone(
      exerciseId: _exerciseId,
      repsCompleted: _reps,
    );

    if (!mounted) return;

    if (allDone) {
      // Full day complete — show celebration then pop
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A2A1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '🎉 Day Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'You finished all 6 exercises for today!\nKeep up the streak! 🔥',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Just one exercise done — show brief snack
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2EA043),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              '✅ $_exerciseName done! Keep going!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _poseService.dispose();
    super.dispose();
  }

  String get _targetLabel {
    if (_targetReps == 0) {
      return '${_avgRepSeconds}s hold';
    }
    return '$_reps / $_targetReps reps';
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),

          // Skeleton overlay
          if (_currentPose != null && _imageSize != Size.zero)
            SizedBox.expand(
              child: CustomPaint(
                painter: PosePainter(
                  _currentPose,
                  imageSize: _imageSize,
                  isFrontCamera: true,
                ),
              ),
            ),

          // Exercise name (very top)
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _exerciseName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // Rep / hold counter
          Positioned(
            top: 88,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _targetLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

          // Feedback (bottom)
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
