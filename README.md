# 🎭 ![App Icon](assets/icon.png) FaceRecognitionPOC 🚀

FaceRecognitionPOC is a Flutter-based proof of concept for face recognition using machine learning models. This project leverages Google's ML Kit for face detection and TensorFlow Lite for on-device machine learning.

## Features
- 🧑‍💻 Face detection using Google ML Kit
- 📷 Camera integration for real-time face analysis
- 🤖 TensorFlow Lite model (FaceNet) for face recognition
- 💾 Shared Preferences for data storage
- 📱 Works on both Android and iOS

## Tech Stack
### Framework & Language
- 🏗️ Flutter (Dart)

### Dependencies
- 🔍 `google_mlkit_face_detection`: Face detection using ML Kit
- 📸 `camera`: Access device camera for real-time processing
- 🖼️ `image`: Image manipulation
- 🧠 `tflite_flutter`: Run TensorFlow Lite models
- 🔐 `shared_preferences`: Store small amounts of data locally
- 🔄 `flutter_plugin_android_lifecycle`: Handles Android lifecycle for Flutter plugins
- 🍏 `cupertino_icons`: iOS-style icons

## Setup Instructions
### Prerequisites
- 🛠️ Flutter SDK `>=3.3.4 <4.0.0`
- 📝 Dart installed
- 🏢 Android Studio or Xcode for development

### Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/your-repo/facerecognitionpoc.git
   cd facerecognitionpoc
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

## Project Structure
```
facerecognitionpoc/
│── lib/                    # 📂 Main application files
│   ├── main.dart           # 🚀 Entry point of the app
│   ├── face_recognition.dart # 🎭 Face recognition logic
│── assets/models/          # 🧠 ML model files
│   ├── facenet.tflite      # 🤖 FaceNet model for feature extraction
│── android/                # 🤖 Android-specific configurations
│── ios/                    # 🍏 iOS-specific configurations
│── pubspec.yaml            # 📜 Flutter dependencies and configurations
```

## Running on iOS
For iOS, you need to enable ML Kit and TensorFlow Lite:
1. Navigate to the iOS folder:
   ```sh
   cd ios
   ```
2. Install pods:
   ```sh
   pod install
   ```
3. Run the project:
   ```sh
   flutter run
   ```

## Running on Android
- Ensure that your `AndroidManifest.xml` has the necessary permissions for camera and storage.
- Run the app using:
   ```sh
   flutter run
   ```
 
 