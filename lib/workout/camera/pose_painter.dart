import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose? pose;
  final Size imageSize; // the camera image resolution (e.g., 640x480)
  final bool isFrontCamera;

  PosePainter(this.pose, {required this.imageSize, this.isFrontCamera = true});

  @override
  void paint(Canvas canvas, Size screenSize) {
    if (pose == null) return;

    // Scale factors: map image coordinates to screen pixel coordinates.
    // Images are rotated 90 degrees so image width maps to screen height.
    final scaleX = screenSize.width / imageSize.height;
    final scaleY = screenSize.height / imageSize.width;

    Offset toScreen(PoseLandmark lm) {
      // Image is sideways (sensor is rotated 90deg): swap x/y when projecting.
      double sx = lm.y * scaleX;
      double sy = lm.x * scaleY;

      // Front camera is mirrored: flip X axis
      if (isFrontCamera) sx = screenSize.width - sx;

      return Offset(sx, sy);
    }

    final bonePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final jointBorderPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final landmarks = pose!.landmarks;

    void drawBone(PoseLandmarkType a, PoseLandmarkType b) {
      final p1 = landmarks[a];
      final p2 = landmarks[b];
      if (p1 == null || p2 == null) return;
      if (p1.likelihood < 0.4 || p2.likelihood < 0.4) return;
      canvas.drawLine(toScreen(p1), toScreen(p2), bonePaint);
    }

    // --- Skeleton connections ---
    // Face
    drawBone(PoseLandmarkType.leftEar, PoseLandmarkType.leftEye);
    drawBone(PoseLandmarkType.leftEye, PoseLandmarkType.nose);
    drawBone(PoseLandmarkType.nose, PoseLandmarkType.rightEye);
    drawBone(PoseLandmarkType.rightEye, PoseLandmarkType.rightEar);

    // Shoulders
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);

    // Left arm
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawBone(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);

    // Right arm
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawBone(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    // Torso
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawBone(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    // Left leg
    drawBone(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawBone(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawBone(PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel);
    drawBone(PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex);

    // Right leg
    drawBone(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawBone(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    drawBone(PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel);
    drawBone(PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex);

    // --- Draw joints (only high-confidence ones) ---
    for (final entry in landmarks.entries) {
      final lm = entry.value;
      if (lm.likelihood < 0.4) continue;
      final pt = toScreen(lm);
      canvas.drawCircle(pt, 6, jointPaint);
      canvas.drawCircle(pt, 6, jointBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}
