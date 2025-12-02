// lib/widgets/video_trimmer_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final File file;

  TrimmerView(this.file);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 5.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? _value;

    await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (value) {
          setState(() {
            _progressVisibility = false;
            _value = value;
          });
        });

    return _value;
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
        foregroundColor: Colors.white,
        title: const Text('Trim video'),
        actions: [
          TextButton(
            onPressed: _progressVisibility
                ? null
                : () async {
                    _saveVideo().then((outputPath) {
                      print('OUTPUT PATH: $outputPath');
                      Navigator.pop(context, outputPath);
                    });
                  },
            child: const Text("Save", style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: const Duration(seconds: 5),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? const Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
