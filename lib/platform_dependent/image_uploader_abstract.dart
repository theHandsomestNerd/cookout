import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

abstract class ImageUploader extends ChangeNotifier {
  late List<XFile?>? files;
  late XFile? file;
  late String? fileExtension;
  late String? contentType;
  // late XFile? pickedFile;
  CroppedFile? croppedFile;

  Future<XFile?> uploadImage();
  void clear();
  Widget body(BuildContext context, double screenWidth, double screenHeight, ImageProvider? imageProvider);
  }