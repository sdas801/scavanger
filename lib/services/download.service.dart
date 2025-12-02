import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scavenger_app/services/common.service.dart';
import 'package:scavenger_app/services/notification.service.dart';
import 'package:gallery_saver_plus/files.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/services.dart';

Future<String> getFilePath(String fileName) async {
  if (Platform.isAndroid) {
    final directory = await getExternalStorageDirectory();
    return "${directory?.parent.parent.parent.parent.path}/Download/$fileName";
  } else if (Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$fileName";
  } else {
    throw UnsupportedError("Unsupported platform");
  }
}

Future<void> downloadVideo(String url, String fileName) async {
  Dio dio = Dio();
  try {
    if (Platform.isAndroid) {
      await requestStoragePermission(); // Request permission
      String filePath = await getFilePath(fileName);

      print("filePath $url$fileName");
      print("filePath $url$filePath");

      await dio.download(url, filePath);
      await saveVideoToGallery(filePath);
      print("filePath $url$filePath");
      await showNotification(filePath);
    } else {
      // iOS (and other non-Android) branch
      String filePath = await getFilePath(fileName);

      print("downloadVideo iOS -> url: $url");
      print("downloadVideo iOS -> local filePath: $filePath");

      // iOS: request Photos permission before saving
      if (Platform.isIOS) {
        final ps = await PhotoManager.requestPermissionExtend();
        if (!ps.isAuth && !ps.hasAccess) {
          Fluttertoast.showToast(
            msg: "Please allow Photos access to save the video",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          await PhotoManager.openSetting();
          return;
        }
      }

      // Download video to local path
      await dio.download(url, filePath);

      // Save to Photos / gallery
      try {
        await saveVideoToGallery(filePath);
      } on PlatformException catch (e, st) {
        print("saveVideoToGallery iOS error: ${e.code} - ${e.message}");
        print(st);
        Fluttertoast.showToast(
          msg: "Failed to save video to gallery",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      // Notify user (your existing function)
      await showNotification(filePath);

      if (Platform.isIOS) {
        Fluttertoast.showToast(
          msg: "Video download Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    if (Platform.isIOS) {
      // Already saved to Photos above; nothing extra needed here.
    }
  } on DioError catch (e) {
    print("Download failed: ${e.message}");
    if (e.response != null) {
      print("Response data: ${e.response?.data}");
      print("Response status code: ${e.response?.statusCode}");
    }
  }
}

Future<void> saveVideoToGallery(String filePath) async {
  print(" Saved to 111gallery: ");
  final file = File(filePath);
  final asset = await PhotoManager.editor.saveVideo(
    file,
    title: filePath.split('.').first, // or any custom title
  );
  print("📁 Saved to gallery: $asset");
}

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:photo_manager/photo_manager.dart';

// Future<void> requestStoragePermission() async {
//   if (Platform.isAndroid) {
//     await [
//       Permission.storage,
//       Permission.videos,
//       Permission.manageExternalStorage, // For Android 11+
//     ].request();
//   }
// }

// Future<String> getFilePath(String fileName) async {
//   final directory = await getTemporaryDirectory(); // Use temp for save
//   return '${directory.path}/$fileName';
// }

// Future<void> downloadVideo(String url, String fileName) async {
//   Dio dio = Dio();
//   try {
//     // Request permissions
//     final permission = await PhotoManager.requestPermissionExtend();
//     if (!permission.isAuth) {
//       Fluttertoast.showToast(msg: "Permission denied");
//       return;
//     }

//     // Get temporary file path
//     String filePath = await getFilePath(fileName);

//     // Download the video
//     await dio.download(url, filePath);
//     print("Video downloaded to $filePath");

//     // Save to gallery using PhotoManager
//     final asset = await PhotoManager.editor.saveVideo(
//       filePath as File,
//       title: fileName.split('.').first, // or any custom title
//     );
//     if (asset != null) {
//       Fluttertoast.showToast(msg: "Video saved to gallery!");
//       print("✅ Saved to gallery: ${asset.id}");
//     } else {
//       Fluttertoast.showToast(msg: "Failed to save video.");
//     }
//   } on DioError catch (e) {
//     print("❌ Download error: ${e.message}");
//     Fluttertoast.showToast(msg: "Download failed: ${e.message}");
//   }
// }
