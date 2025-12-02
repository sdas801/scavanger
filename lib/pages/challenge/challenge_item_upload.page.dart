import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:scavenger_app/pages/custom_camera.dart';
import 'package:scavenger_app/pages/utility/video_trimmer_page.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/challenge.model.dart';
import 'package:scavenger_app/services/orientation.dart';
import 'package:scavenger_app/shared/video.widget.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:scavenger_app/services/common.service.dart';

class ItemUpload {
  int id;
  String imageUrl;
  String name;
  String description;
  String uploadedimg;
  bool isUploading;
  dynamic snapshot;
  int? sequence;

  ItemUpload({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.uploadedimg,
    required this.isUploading,
    required this.snapshot,
    this.sequence,
  });

  /// ✅ Convert a JSON map into an ItemUpload instance
  factory ItemUpload.fromJson(Map<String, dynamic> json) {
    return ItemUpload(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      uploadedimg: json['uploadedimg'] ?? '',
      isUploading: json['isUploading'] ?? false,
      snapshot: json['snapshot'],
      sequence: json['sequence'],
    );
  }

  /// ✅ Convert ItemUpload instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'description': description,
      'uploadedimg': uploadedimg,
      'isUploading': isUploading,
      'snapshot': snapshot,
      'sequence': sequence,
    };
  }
}

class ChallengeItemUploadPage extends StatefulWidget {
  const ChallengeItemUploadPage({super.key, required this.gameId});
  final int gameId;
  @override
  _ChallengeItemUploadPageState createState() =>
      _ChallengeItemUploadPageState();
}

class _ChallengeItemUploadPageState extends State<ChallengeItemUploadPage> {
  List<ChallengeItem> items = [];
  List<ItemUpload> uploadItemList = [];
  bool _isLoading = false;
  int uploadItemid = 0;
  File? galleryFile;
  final picker = ImagePicker();
  String uplodedImgUrl = "";
  String name = '';
  String description = '';
  String imageUrl = '';
  final ImagePicker _picker = ImagePicker();
  File? _videoFile;
  OrientationService orientationService = OrientationService();
  CameraController? _controller;
  String currentorientation = '';
  int oriantation = 0;
  late Future<void> _initializeControllerFuture;
  bool isRecording = false;
  String? videoPath;

  @override
  void initState() {
    super.initState();
    _getChallengeDetails();

    orientationService.startListening((orientation) {
      if (mounted)
        setState(() {
          currentorientation = orientation;
        });
    });

    // _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    await Permission.camera.request();

    _controller = CameraController(cameras.first, ResolutionPreset.medium);

    _initializeControllerFuture = _controller?.initialize() ?? Future.value();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    orientationService.stopListening();
    super.dispose();
  }

  // NOTE: Added mounted checks in _getChallengeDetails success block
  _getChallengeDetails() async {
    if (mounted)
      setState(() {
        _isLoading = true;
      });

    ApiService.getChallengeDetails(widget.gameId).then((res) {
      if (res.success) {
        if (mounted)
          setState(() {
            final game = ChallengeModel.fromJson(res.response);

            log(
              "this is the item of the quest item >>>>>>>>> ${game.items?.map((i) => i.toJson())}",
            );

            items = game.items ?? [];
            _isLoading = false;

            name = game.name;
            description = game.description;
            imageUrl = game.imageurl ?? '';

            setItemForUpdload();
          });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load quest details: ${res.message}'),
          ),
        );
      }
    });
  }

  void markAsComplete() {
    ApiService.markAsComplete({"challengeid": widget.gameId}).then((res) {
      if (res.success) {
        goHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark Quests as completed: ${res.message}'),
          ),
        );
      }
    });
  }

  _onShowDiolog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm End Quest',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B00AB),
            ),
          ),
          content: const Text(
            'Are you sure you want to mark as ended',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                markAsComplete();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF0B00AB),
              ),
              child: const Text('End Quest', style: TextStyle(fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  goHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const HomeScreen(
                userName: '',
                selectedTab: 1,
              )),
    );
  }

  setItemForUpdload() {
    uploadItemList = [];

    for (var item in items) {
      uploadItemList.add(
        ItemUpload(
          id: item.id,
          imageUrl: item.imageurl ?? '',
          name: item.itemname ?? '',
          description: item.description ?? '',
          uploadedimg: item.uploadedimg ?? "",
          isUploading: false,
          snapshot: item.snapshot,
          sequence: item.sequence,
        ),
      );
    }

    log("uploaded item >>>>>>>>>>> ${uploadItemList.map((i) => i.toJson())}");
  }

  // --- Helper function to show errors to the user ---
  void _showUserError(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Media Processing Failed: $message',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void onImageCapture(int itid, bool isCamera) async {
    final ImagePicker picker = ImagePicker();
    // Get context before the first async gap
    final BuildContext context = this.context;
    bool loadingStateSet = false;

    try {
      final XFile? pickedFile = await picker.pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 25,
          maxHeight: 800,
          maxWidth: 800);

      if (pickedFile == null) {
        debugPrint("Image capture cancelled by user.");
        return;
      }

      File originalImage = File(pickedFile.path);

      // 2. Set Uploading State (with mounted check)
      if (mounted) {
        setState(() {
          uploadItemList.firstWhere((item) => item.id == itid).isUploading =
              true;
          loadingStateSet = true;
        });
      } else {
        debugPrint("Widget unmounted after picking image. Aborting.");
        return;
      }

      // 3. Image Processing
      final result = await compute(processImageRotation, {
        'path': originalImage.path,
        'orientation': currentorientation,
      });

      galleryFile = File(result['path']);
      // oriantation is an int, result['orientation'] is dynamically typed, should be checked
      if (result['orientation'] is int) {
        oriantation = result['orientation'] as int;
      } else {
        // Fallback if orientation processing failed/returned wrong type
        oriantation = 0;
      }

      // 4. Check processed file existence and start upload
      if (galleryFile != null && galleryFile!.existsSync()) {
        await _uploadImage(itid, "image", oriantation);
      } else {
        throw Exception("Processed image file not found or corrupted.");
      }
    } catch (e) {
      debugPrint("FATAL Error during image capture: $e");
      // 5. Catch ALL errors and reset UI state
      if (mounted) {
        String userMessage = e.toString().contains("Permission")
            ? "Camera/Gallery permission denied."
            : "An error occurred during image processing or rotation. Please try again.";

        _showUserError(context, userMessage);

        // Reset the loading state regardless of the error type
        if (loadingStateSet) {
          if (mounted)
            setState(() {
              uploadItemList.firstWhere((item) => item.id == itid).isUploading =
                  false;
            });
        }
      }
    }
  }

  Future<void> _uploadImage(int itid, String type, int oriantation) async {
    if (galleryFile == null && _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image to upload')),
      );
      return;
    }

    ApiService.uploadFile(
      type == "image" ? galleryFile!.path : _videoFile!.path,
    ).then((value) async {
      if (mounted)
        setState(() {
          _isLoading = false;
        });

      if (value != '') {
        String uploadedImgUrl = value;
        print("===========$oriantation");
        _uploaditem(itid, uploadedImgUrl, oriantation);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload failed')));
      }
    });
  }

  Future<void> _uploaditem(uploadid, imgurl, oriantation) async {
    ApiService.uploadItemImage({
      "id": uploadid,
      "imageurl": imgurl,
      "orientation": oriantation,
    }).then((value) async {
      if (value.success) {
        log("this is the valus of resokgjfndg >>>>>>>.${value.response}");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Item uploaded successfully')));
        if (mounted)
          setState(() {
            for (var item in uploadItemList) {
              if (item.id == uploadid) {
                item.isUploading = false;
                item.uploadedimg = imgurl;
              }
            }
          });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item upload failed: ${value.message}')),
        );
      }
    });
  }

  Future<dynamic> openVideoCamera() async {
    final cameras = await availableCameras();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenCameraModal(
          durationSeconds: 5,
          cameras: cameras,
        ),
      ),
    );

    if (result != null && result is File) {
      print("Video saved at: ${result.path}");
      // Upload or process the video
      return result.path;
    } else {
      return null;
    }
  }

  Future<void> onVideoCapture(int itid, bool isCamera) async {
    // Get context before the first async gap
    final BuildContext context = this.context;
    bool loadingStateSet = false;

    try {
      final XFile? vid = await _picker.pickVideo(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          maxDuration: const Duration(seconds: 5));

      String video = vid?.path ?? '';

      if (video == '') {
        debugPrint("Video capture cancelled by user or no file selected.");
        return;
      }

      // Set Uploading State
      if (mounted) {
        setState(() {
          uploadItemList.firstWhere((item) => item.id == itid).isUploading =
              true;
          loadingStateSet = true;
          _videoFile = File(video); // Set _videoFile early
        });
      } else {
        debugPrint("Widget unmounted after picking video. Aborting.");
        return;
      }

      // Navigate to Trimmer View
      final trimmedPath = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return TrimmerView(File(video));
        }),
      );

      if (trimmedPath != null && trimmedPath is String) {
        video = trimmedPath;
        // Update _videoFile path if trimming was successful
        _videoFile = File(video);
      } else {
        // User cancelled trimming
        throw Exception("Video trimming cancelled by user.");
      }

      // Re-initialize player with trimmed video
      VideoPlayerController controller =
          VideoPlayerController.file(File(video));
      await controller.initialize();

      // Check duration
      final Duration duration = controller.value.duration;
      if (duration.inSeconds > 5) {
        await controller.dispose();
        throw Exception(
            "Video duration exceeds 5 seconds limit. Duration: ${duration.inSeconds}s");
      }

      // Determine orientation logic (kept as original, now inside try block)
      int width = controller.value.size.width.toInt();
      int height = controller.value.size.height.toInt();
      String videoOrientation = width > height ? "Landscape" : "Portrait";

      if (videoOrientation == "Portrait") {
        oriantation = 1;
      } else {
        oriantation = 0;
      }

      await controller.dispose();

      // Final upload call
      await _uploadImage(itid, "video", oriantation);
    } catch (e) {
      log("FATAL Error during video capture: $e");

      // 5. Catch ALL errors and reset UI state
      if (mounted) {
        String userMessage = e.toString().contains("Permission")
            ? "Camera/Gallery permission denied."
            : e.toString().contains("trimming cancelled")
                ? "Video processing cancelled."
                : e.toString().contains("duration exceeds")
                    ? "Video is too long (max 5 seconds)."
                    : "An unexpected error occurred during video processing.";

        _showUserError(context, userMessage);

        // Reset the loading state regardless of the error type
        if (loadingStateSet) {
          if (mounted)
            setState(() {
              uploadItemList.firstWhere((item) => item.id == itid).isUploading =
                  false;
              _videoFile = null; // Clear video file on failure
            });
        }
      }
    }
  }

  Future<String> getDeviceOrientation() async {
    try {
      AccelerometerEvent event = await accelerometerEvents.first;
      double x = event.x;
      double y = event.y;

      if (x.abs() > y.abs()) {
        return "Landscape";
      } else {
        return "Portrait";
      }
    } catch (e) {
      print("Error detecting orientation: $e");
      return "Unknown";
    }
  }

  // void onItemTapped(BuildContext context, int itid) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Choose Media Type"),
  //         content: const Text("Do you want to select a picture or a video?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               // _showSourceDialog(
  //               //   context,
  //               //   itid,
  //               //   isImage: true,
  //               // );
  //               onImageCapture(itid, true);
  //             },
  //             child: const Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.image, color: Colors.blue),
  //                 SizedBox(width: 8),
  //                 Text("Picture"),
  //               ],
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               // _showSourceDialog(
  //               //   context,
  //               //   itid,
  //               //   isImage: false,
  //               // );
  //               onVideoCapture(itid, true);
  //             },
  //             child: const Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.videocam, color: Colors.red),
  //                 SizedBox(width: 8),
  //                 Text("Video"),
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void onItemTapped(BuildContext context, int itid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Media Type"),
          content: const Text("Do you want to select a picture or a video?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSourceDialog(
                  context,
                  itid,
                  isImage: true,
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Picture"),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSourceDialog(
                  context,
                  itid,
                  isImage: false,
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Video"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSourceDialog(BuildContext context, int itid,
      {required bool isImage}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Source'),
          content: const Text('Do you want to use Camera or Gallery?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isImage) {
                  onImageCapture(itid, true); // open camera for image
                } else {
                  onVideoCapture(itid, true); // open camera for video
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Camera"),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isImage) {
                  onImageCapture(itid, false); // gallery for image
                } else {
                  onVideoCapture(itid, false); // gallery for video
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Gallery"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // void _showSourceDialog(
  //   BuildContext context,
  //   int itid, {
  //   required bool isImage,
  // }) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select Source'),
  //         content: Text('Do you want to use Camera or Gallery?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);

  //               if (isImage) {
  //                 onImageCapture(itid, true);
  //               } else {
  //                 onVideoCapture(itid, true);
  //               }
  //             },
  //             child: Row(
  //               children: [
  //                 Icon(Icons.camera_alt, color: Colors.green),
  //                 SizedBox(width: 8),
  //                 Text("Camera"),
  //               ],
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);

  //               if (isImage) {
  //                 onImageCapture(itid, false);
  //               } else {
  //                 onVideoCapture(itid, false);
  //               }
  //             },
  //             child: Row(
  //               children: [
  //                 Icon(Icons.photo_library, color: Colors.orange),
  //                 SizedBox(width: 8),
  //                 Text("Gallery"),
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void onItemTappedlist(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Description"),
          content: Text(description),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quest Items'),
        backgroundColor: Color(0xFF0B00AB),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color(0xFF0B00AB),
      body: Skeletonizer(
        enabled: _isLoading,
        enableSwitchAnimation: true,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF153792), width: 3),
                ),
                child: imageUrl != ''
                    ? ClipOval(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (ctx, err, st) {
                            return Image.asset('assets/images/defaultImg.jpg');
                          },
                        ),
                      )
                    : CircleAvatar(
                        radius: 75,
                        backgroundImage: AssetImage(
                          'assets/images/defaultImg.jpg',
                        ),
                      ),
              ),
              Text(
                name,
                style: TextStyle(
                  color: Color(0xFF153792),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF153792),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: uploadItemList.length,
                  itemBuilder: (context, index) {
                    dynamic newitem;

                    if (uploadItemList[index].sequence != 0 &&
                        uploadItemList[index].sequence != null) {
                      newitem = uploadItemList.firstWhere(
                        (item) => item.sequence == index + 1,
                      );
                    } else {
                      newitem = uploadItemList[index];
                    }

                    return ListItem(
                      item: newitem,
                      onItemTapped: onItemTapped,
                      onItemTappedlist: onItemTappedlist,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: goHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0B00AB),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Return to Dashboard',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _onShowDiolog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0B00AB),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'End Quest',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

_showVideoDialog(BuildContext context, String url) {
  var vUrl = url;
  return showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: SizedBox(
                height: 300,
                width: 450,
                child: VideoWidget(url: vUrl, play: true)));
      });
}

void _showImagePopup(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

typedef ItemTappedCallback = void Function(BuildContext context, int name);
typedef ItemTappedlistCallback = void Function(
    BuildContext context, String name);

class ListItem extends StatelessWidget {
  final ItemUpload item;
  final ItemTappedCallback onItemTapped;
  final ItemTappedlistCallback onItemTappedlist;
  const ListItem(
      {super.key,
      required this.item,
      required this.onItemTapped,
      required this.onItemTappedlist});

  @override
  Widget build(BuildContext context) {
    bool isVideo = item.uploadedimg != null &&
        (item.uploadedimg.endsWith(".mp4") ||
            item.uploadedimg.endsWith(".MOV") ||
            item.uploadedimg.endsWith(".mov"));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              item.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; // Show the image when fully loaded
                }
                return const Center(
                  child:
                      CircularProgressIndicator(), // Show a loader while the image is loading
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/defaultImg.jpg',
                  width: 50,
                  height: 50,
                ); // Fallback for broken image
              },
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(21, 55, 146, 1.0),
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color.fromRGBO(70, 81, 111, 1),
                    fontSize: 14.0,
                    height: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.description.isNotEmpty && item.description.length > 30)
                  GestureDetector(
                    onTap: () {
                      onItemTappedlist(context, item.description);
                    },
                    child: const Text(
                      "Show More",
                      style: TextStyle(
                        color: Color.fromRGBO(70, 81, 111, 1),
                        fontSize: 14.0,
                        height: 1,
                        decoration: TextDecoration
                            .underline, // Optional: underline for interactivity
                      ),
                    ),
                  ),
                const SizedBox(height: 4.0),
              ],
            ),
          ),
          item.isUploading
              ? const CircularProgressIndicator()
              : item.uploadedimg == ''
                  ? IconButton(
                      icon: Icon(
                        Icons.camera_alt_sharp,
                        size: 40,
                        color: Colors.green,
                        shadows: [
                          Shadow(
                            color: const Color.fromARGB(255, 199, 199, 199)
                                .withOpacity(0.5),
                            offset: const Offset(3, 3),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      // icon: const Image(
                      //   image: AssetImage('assets/images/upload_ico.png'),
                      //   height: 50,
                      //   width: 50,
                      // ),
                      onPressed: () {
                        // Handle the upload button action
                        //huntdash.getImage(ImageSource.gallery,item.id);
                        //onImageSelected;
                        onItemTapped(context, item.id);
                      },
                    )
                  : isVideo
                      ? GestureDetector(
                          onTap: () =>
                              _showVideoDialog(context, item.uploadedimg),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              item.snapshot != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(item
                                          .snapshot), // Placeholder for video
                                      radius: 30.0,
                                    )
                                  : const CircleAvatar(
                                      backgroundImage: AssetImage(
                                          "assets/images/logo.jpg"), // Placeholder for video
                                      radius: 30.0,
                                    ),
                              const Icon(
                                Icons.play_circle_fill,
                                color: Color.fromRGBO(21, 55, 146, 1.0),
                                size: 30.0,
                              ),
                            ],
                          ))
                      : GestureDetector(
                          onTap: () =>
                              _showImagePopup(context, item.uploadedimg),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(item.uploadedimg),
                            radius: 30.0,
                          ),
                        ),
          // more menu
          PopupMenuButton(
            enabled: item.uploadedimg != '',
            onSelected: (menu) {
              if (menu == 'change') {
                onItemTapped(context, item.id);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(value: 'change', child: Text('Change')),
            ],
          ),
        ],
      ),
    );
  }
}

class Item {
  final String imageUrl;
  final String name;
  final String description;
  final String status;

  Item({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.status,
  });
}
