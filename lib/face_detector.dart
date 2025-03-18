import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<List<Face>> detectFaces(File imageFile, BuildContext context) async {
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      // Ensure only one face is detected
      if (faces.length != 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Only one face should be visible!")),
        );
        return [];
      }

      // Process detected face contours
      final Face face = faces.first;
      final contours = face.contours;

      final Map<String, FaceContour?> faceContours = {
        "Face": contours[FaceContourType.face],
        "Left Eye": contours[FaceContourType.leftEye],
        "Right Eye": contours[FaceContourType.rightEye],
        "Left Eyebrow Top": contours[FaceContourType.leftEyebrowTop],
        "Left Eyebrow Bottom": contours[FaceContourType.leftEyebrowBottom],
        "Right Eyebrow Top": contours[FaceContourType.rightEyebrowTop],
        "Right Eyebrow Bottom": contours[FaceContourType.rightEyebrowBottom],
        "Nose Bridge": contours[FaceContourType.noseBridge],
        "Nose Bottom": contours[FaceContourType.noseBottom],
        "Upper Lip Top": contours[FaceContourType.upperLipTop],
        "Upper Lip Bottom": contours[FaceContourType.upperLipBottom],
        "Lower Lip Top": contours[FaceContourType.lowerLipTop],
        "Lower Lip Bottom": contours[FaceContourType.lowerLipBottom],
        "Left Cheek": contours[FaceContourType.leftCheek],
        "Right Cheek": contours[FaceContourType.rightCheek],
      };

      // Print detected contours
      faceContours.forEach((key, contour) {
        if (contour != null) {
          print('$key contour points: ${contour.points.length}');
        }
      });
      return faces;
    } catch (e) {
      print("Error detecting faces: $e");
      return [];
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
