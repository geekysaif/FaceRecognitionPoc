import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'face_detector.dart';
import 'face_embedding.dart';

class FaceLoginScreen extends StatefulWidget {
  @override
  _FaceLoginScreenState createState() => _FaceLoginScreenState();
}

class _FaceLoginScreenState extends State<FaceLoginScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  FaceDetectorService faceDetectorService = FaceDetectorService();
  FaceEmbedding faceEmbedding = FaceEmbedding();

  Map<String, List<double>> storedFaceEmbeddings = {}; // Stores embeddings for each position
  List<String> facePositions = ["Center", "Left", "Right", "Up", "Down"];
  int captureStep = 0; // Track current position
  bool isLoginEnabled = false;
  bool isRegisterCompleted = false;
  double matchThreshold = 0.85;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await faceEmbedding.loadModel();
    await _initializeCamera();
    setState(() {});
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras!.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      setState(() {});
    }
  }

  Future<void> _registerFace() async {
    if (!faceEmbedding.isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Model not loaded! Please wait...")),
      );
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final XFile picture = await _cameraController!.takePicture();
    final File imageFile = File(picture.path);
    final faces = await faceDetectorService.detectFaces(imageFile,context);

    if (faces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No Face Detected! Try again.")),
      );
      return;
    }

    List<double> newEmbedding = faceEmbedding.getFaceEmbedding(imageFile);

    if (newEmbedding.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to extract face embedding!")),
      );
      return;
    }

    // Validate similarity with the first (center) face before adding new embeddings
    if (captureStep > 0) {
      double similarity = faceEmbedding.calculateCosineSimilarity(
        storedFaceEmbeddings["Center"]!,
        newEmbedding,
      );
      if (similarity < matchThreshold) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${facePositions[captureStep]} face does not match the Center face! Try again.")),
        );
        return;
      }
    }

    // Store the face embedding for the current position
    storedFaceEmbeddings[facePositions[captureStep]] = newEmbedding;
    print("${facePositions[captureStep]} Face Registered: $newEmbedding");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${facePositions[captureStep]} Face Registered!")),
    );
    // Move to the next step
    captureStep++;

    if (captureStep >= facePositions.length) {
      captureStep = facePositions.length; // Ensure it does not exceed the max steps
      isRegisterCompleted = true; // Disable register button
      isLoginEnabled = true; // Enable login button
    }

    setState(() {});

  }

  Future<void> _matchFace() async {
    if (!isLoginEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please register all face angles first.")),
      );
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final XFile picture = await _cameraController!.takePicture();
    final File imageFile = File(picture.path);
    final faces = await faceDetectorService.detectFaces(imageFile,context);

    if (faces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No Face Detected! Try again.")),
      );
      return;
    }

    List<double> newFaceEmbedding = faceEmbedding.getFaceEmbedding(imageFile);

    if (newFaceEmbedding.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to extract face embedding!")),
      );
      return;
    }

    double maxSimilarity = 0.0;
    for (var storedEmbedding in storedFaceEmbeddings.values) {
      double similarity = faceEmbedding.calculateCosineSimilarity(storedEmbedding, newFaceEmbedding);
      maxSimilarity = max(maxSimilarity, similarity);
      print("Matching score: $similarity");
    }

    print("Highest Similarity Score: $maxSimilarity");

    if (maxSimilarity > matchThreshold) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Face Matched! Login Successful")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Face Not Recognized")),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    faceDetectorService.dispose();
    faceEmbedding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Recognition Login")),
      body: Column(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Container(
              height: 400,
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),

          const SizedBox(height: 20),

          Text(
            isRegisterCompleted ? "Face Registration Complete!" : "Move your face to: ${facePositions[captureStep]}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "$captureStep/5 Registered",
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: isRegisterCompleted ? null : _registerFace, // Disable after 5/5
            child: Text("Capture Face (${captureStep}/5)"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRegisterCompleted ? Colors.grey : Colors.blue,
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: isLoginEnabled ? _matchFace : null,
            child: Text("Login with Face"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLoginEnabled ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
