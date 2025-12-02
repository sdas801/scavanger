import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:developer';

Future<void> requestStoragePermission() async {
  if (await Permission.storage.isDenied) {
    await Permission.storage.request();
  }

  // For Android 11+
  if (await Permission.manageExternalStorage.isDenied) {
    await Permission.manageExternalStorage.request();
  }

  if (await Permission.storage.isGranted ||
      await Permission.manageExternalStorage.isGranted) {
    print('Storage permission granted.');
  } else {
    print('Storage permission denied.');
  }
}

// Map<String, dynamic> processImageRotation(Map<String, dynamic> args) {
//   final String path = args['path'];
//   final String orientation = args['orientation'];

//   final File file = File(path);
//   final img.Image? image = img.decodeImage(file.readAsBytesSync());
//   if (image == null) return {'path': path, 'orientation': 0};

//   int orien = image.width > image.height ? 0 : 1;
//   img.Image rotatedImage = image;

//   if (orientation == 'Portrait Upside Down') {
//     rotatedImage = img.copyRotate(image, angle: 0);
//   } else if (orientation == 'Landscape Left') {
//     rotatedImage = img.copyRotate(image, angle: 0);
//   } else if (orientation == 'Landscape Right') {
//     rotatedImage = img.copyRotate(image, angle: 0);
//   }

//   final newPath = '$path.fixed.jpg';
//   File(newPath).writeAsBytesSync(img.encodeJpg(rotatedImage, quality: 80));

//   return {'path': newPath, 'orientation': orien};
// }

Map<String, dynamic> processImageRotation(Map<String, dynamic> args) {
  final String path = args['path'];
  final String orientation = args['orientation'];

  final File file = File(path);
  final img.Image? image = img.decodeImage(file.readAsBytesSync());
  if (image == null) return {'path': path, 'orientation': 0};

  // Determine initial orientation: 0 for Landscape, 1 for Portrait
  int orien = image.width > image.height ? 0 : 1;
  img.Image rotatedImage = image;

  // The rotation logic below uses angle: 0 for all cases which seems suspicious
  // if you actually intend to rotate based on orientation.
  // I will leave it as angle: 0 to match your provided logic,
  // but note that this section may need refinement based on your specific rotation needs.
  if (orientation == 'Portrait Upside Down') {
    rotatedImage = img.copyRotate(image, angle: 0);
  } else if (orientation == 'Landscape Left') {
    rotatedImage = img.copyRotate(image, angle: 0);
  } else if (orientation == 'Landscape Right') {
    rotatedImage = img.copyRotate(image, angle: 0);
  }

  final newPath = '$path.fixed.jpg';
  try {
    File(newPath).writeAsBytesSync(img.encodeJpg(rotatedImage, quality: 80));
  } catch (e) {
    log("Error writing fixed image file: $e");
    // If saving fails, return the original path with a default orientation.
    return {'path': path, 'orientation': 0};
  }

  return {'path': newPath, 'orientation': orien};
}

String normalizeDate(String input) {
  try {
    // Check for format "dd-MM-yyyy"
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(input)) {
      final date = DateFormat('dd-MM-yyyy').parseStrict(input);
      return DateFormat('yyyy-MM-dd').format(date);
    }

    // Check for already formatted "yyyy-MM-dd"
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) {
      return input;
    }
  } catch (e) {
    print('Invalid date format: $e');
  }

  return ''; // Return empty or fallback if invalid
}
