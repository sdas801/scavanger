import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class CropImageService {
  static Future<dynamic> cropImage(XFile? pickedFile,
      {String cropStyle = 'circle'}) async {
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Your Image',
              toolbarColor: const Color(0xFF0B00AB),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              cropStyle: cropStyle == 'square'
                  ? CropStyle.rectangle
                  : CropStyle.circle,
              // cropStyle: CropStyle.rectangle,
              lockAspectRatio: true,
              hideBottomControls: true,
              showCropGrid: false,
              cropFrameColor: Colors.black12,
              dimmedLayerColor: Colors.black),
        ],
      );
      return croppedFile;
    }
  }
}
