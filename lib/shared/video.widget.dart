import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final bool play;
  bool? isborder = true;

  VideoWidget({Key? key, required this.url, required this.play, this.isborder})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  void initVideo() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {}); // Ensure UI updates after initialization
      }
      if (widget.play) {
        _controller.play();
        setState(() => isPlaying = true);
      }
    });

    _controller.setLooping(false);

    _controller.addListener(() {
      final bool isVideoPlaying = _controller.value.isPlaying;
      final bool isVideoEnded =
          _controller.value.position >= _controller.value.duration;

      if (mounted) {
        setState(() {
          // Sync playing state
          isPlaying = isVideoPlaying && !isVideoEnded;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        isPlaying = false;
      } else {
        _controller.play();
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
          widget.isborder == null || widget.isborder == true ? 50 : 0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: Colors.white,
                  width: widget.isborder == null || widget.isborder == true
                      ? 10
                      : 0), // Border design
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width:
                              // widget.isborder == null || widget.isborder == true
                              //     ? 500
                              //     : null,
                              500,
                          height: 400,
                          child: FittedBox(
                            fit: BoxFit
                                .cover, // Ensures video covers the entire space
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          child: IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              size: 50,
                              color: Colors.white,
                            ),
                            onPressed: togglePlayPause,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
          /* Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.black54, // Set the background color to white
                borderRadius:
                    BorderRadius.circular(50), // Optional: to make it round
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color.fromARGB(255, 245, 241, 241),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ), */
        ],
      ),
    );
  }
}
