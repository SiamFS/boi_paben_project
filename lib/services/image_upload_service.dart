import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static const String _cloudName = 'dtxxuzbne'; // Same as book upload
  static const String _uploadPreset = 'boi_paben_books'; // Same as book upload
  
  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset);
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  // Upload image to Cloudinary
  Future<String> uploadImage(XFile imageFile, {String folder = 'blog_images'}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          publicId: 'blog_${DateTime.now().millisecondsSinceEpoch}',
          folder: folder,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload image from bytes (useful for web)
  Future<String> uploadImageFromBytes(Uint8List bytes, String fileName, {String folder = 'blog_images'}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: fileName,
          folder: folder,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Show image source selection dialog (gallery only, same as book upload)
  Future<XFile?> showImageSourceDialog(context) async {
    final XFile? image = await pickImageFromGallery();
    return image;
  }
}
