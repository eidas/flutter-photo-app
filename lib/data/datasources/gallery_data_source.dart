import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class GalleryDataSource {
  Future<File?> pickImage();
}

class GalleryDataSourceImpl implements GalleryDataSource {
  final ImagePicker _picker = ImagePicker();
  
  @override
  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
