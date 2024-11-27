import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagesController {
  final ImagePicker _picker = ImagePicker();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Capture an image using the camera and compress it
  Future<File?> captureAndCompressImage() async {
    try {
      final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
      if (imageFile == null) return null;

      final File originalImage = File(imageFile.path);
      final File? compressedImage = await _compressImage(originalImage);

      return compressedImage;
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
  }

  /// Compress the image to reduce size
  Future<File?> _compressImage(File image) async {
    try {
      final directory = await getTemporaryDirectory();
      final compressedPath = '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path,
        compressedPath,
        quality: 75, // Adjust quality as needed (0-100)
      );

      return compressedFile==null?null: File(compressedFile.path);
    } catch (e) {
      print("Error compressing image: $e");
      return null;
    }
  }

  /// Save the image as a Base64 string to Firebase Realtime Database
  Future<void> saveImageToRealtimeDatabase({
    required File image,
    required String userId,
    required String collectionName, // "students" or "teachers"
  }) async {
    try {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      final collection = _database.child(collectionName).child(userId);
      await collection.set({"image": base64String});
    } catch (e) {
      print("Error saving image to Realtime Database: $e");
    }
  }

  /// Save the image locally in a secure folder
  Future<File?> saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final localImagePath = '${directory.path}/images';
      final localImageDir = Directory(localImagePath);

      // Create directory if it doesn't exist
      if (!await localImageDir.exists()) {
        await localImageDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localImageFile = File('${localImageDir.path}/$fileName');

      return image.copy(localImageFile.path);
    } catch (e) {
      print("Error saving image locally: $e");
      return null;
    }
  }

  /// Handle the complete process of capturing, compressing, and saving the image
  Future<void> handleImageCapture({
    required String userId,
    required String userType, // "students" or "teachers"
  }) async {
    final File? image = await captureAndCompressImage();
    if (image == null) return;

    // Save locally
    final File? localImage = await saveImageLocally(image);
    if (localImage != null) {
      print("Image saved locally at: ${localImage.path}");
    }

    // Save to Realtime Database
    await saveImageToRealtimeDatabase(image: image, userId: userId, collectionName: userType);
  }
}
