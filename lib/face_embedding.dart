import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbedding {
  late tfl.Interpreter _interpreter;
  //late Interpreter _interpreter;
  bool isModelLoaded = false;


  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset("assets/models/facenet.tflite", options: options);

      _interpreter.allocateTensors();  // Allocate tensors

      isModelLoaded = true;
      print(" Model Loaded Successfully");
    } catch (e) {
      print(" Error loading model: $e");
      isModelLoaded = false;
    }
  }


  List<double> getFaceEmbedding(File imageFile) {
    if (!isModelLoaded) {
      throw Exception("Model not loaded yet! Call `loadModel()` first.");
    }

    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) {
      throw Exception("Failed to decode image!");
    }

    img.Image resizedImage = img.copyResize(image, width: 500, height: 500);
    var input = preprocessImage(resizedImage);

    // Verify model input shape
    print("🔍 Model Input Shape: ${_interpreter.getInputTensor(0).shape}");
    print("🔍 Model Output Shape: ${_interpreter.getOutputTensor(0).shape}");  // ✅ Print actual output shape

    // Adjust output shape based on model's actual output shape
    var outputShape = _interpreter.getOutputTensor(0).shape;
    var output = List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0));

    _interpreter.run(input, output);

    return output[0]; // Ensure correct shape is returned
  }

  List<List<List<List<double>>>> preprocessImage(img.Image image) {
    List<List<List<List<double>>>> input = List.generate(1, (_) =>
        List.generate(112, (_) => //  Fix: Change 160 to 112
        List.generate(112, (_) =>
            List.generate(3, (_) => 0.0)
        )
        )
    );

    for (int y = 0; y < 112; y++) { //  Fix: Change 160 to 112
      for (int x = 0; x < 112; x++) {
        final pixel = image.getPixel(x, y);
        input[0][y][x][0] = (pixel.r - 127.5) / 128;
        input[0][y][x][1] = (pixel.g - 127.5) / 128;
        input[0][y][x][2] = (pixel.b - 127.5) / 128;
      }
    }
    return input;
  }

  double calculateCosineSimilarity(List<double> emb1, List<double> emb2) {
    double dotProduct = 0, normA = 0, normB = 0;

    for (int i = 0; i < emb1.length; i++) {
      dotProduct += emb1[i] * emb2[i];
      normA += emb1[i] * emb1[i];
      normB += emb2[i] * emb2[i];
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  void dispose() {
    _interpreter.close();
  }
}
