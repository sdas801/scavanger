import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FullscreenCameraModal extends StatefulWidget {
  final int durationSeconds;
  final List<CameraDescription> cameras;

  const FullscreenCameraModal({
    super.key,
    required this.durationSeconds,
    required this.cameras,
  });

  @override
  State<FullscreenCameraModal> createState() => _FullscreenCameraModalState();
}

class _FullscreenCameraModalState extends State<FullscreenCameraModal> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _selectedCameraIndex = 0;
  bool _isRecording = false;
  int _remainingSeconds = 0;
  Timer? _timer;
  String targetPath = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera(_selectedCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    _controller =
        CameraController(widget.cameras[cameraIndex], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    if (mounted) setState(() {});
  }

  void _switchCamera() async {
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    await _controller.dispose();
    _initializeCamera(_selectedCameraIndex);
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized) return;

    final Directory dir = await getTemporaryDirectory();
    targetPath = p.join(
      dir.path,
      'challenge_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    await _controller.startVideoRecording();
    setState(() {
      _isRecording = true;
      _remainingSeconds = widget.durationSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds <= 1) {
        timer.cancel();

        final XFile videoFile = await _controller.stopVideoRecording();
        setState(() => _isRecording = false);

        // Move .tmp file to proper .mp4 path
        final File recordedFile = File(videoFile.path);
        final File finalFile = await recordedFile.copy(targetPath);

        Navigator.pop(context, finalFile);
      } else {
        setState(() => _remainingSeconds--);
      }
    });

  }

  Future<void> _stopRecording() async {
    if (_isRecording && _remainingSeconds < widget.durationSeconds) {
      _timer?.cancel();
      try{
        final XFile videoFile = await _controller.stopVideoRecording();
        final File recordedFile = File(videoFile.path);
        final File finalFile = await recordedFile.copy(targetPath);

        Navigator.pop(context, finalFile);
      } catch(e) {}
      setState(() => _isRecording = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Positioned.fill(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.previewSize!.height,
                      height: _controller.value.previewSize!.width,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.cameraswitch,
                      color: Colors.white, size: 30),
                  onPressed: _switchCamera,
                ),
              ),
              if (_isRecording)
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '$_remainingSeconds',
                      style: const TextStyle(
                          fontSize: 32,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    icon: const Icon(Icons.fiber_manual_record),
                    label:
                        Text(_isRecording ? "Stop Recording" : "Start Recording", style: const TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? const Color.fromARGB(255, 255, 60, 0) : const Color.fromARGB(255, 13, 52, 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
