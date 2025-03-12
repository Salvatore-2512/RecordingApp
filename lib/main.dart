import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RecordingScreen(),
    );
  }
}

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final List<double> _waveformData = [];
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));
  }

  void _startRecording() async {
    final path = '${Directory.systemTemp.path}/recording.wav';
    await _recorder.startRecorder(toFile: path);

    _recorder.onProgress!.listen((event) {
      setState(() {
        _waveformData.add(event.decibels ?? 0);
      });
    });

    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Waveform Recorder')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: RectangleWaveform(
                samples: _waveformData,
                height: 200,
                width: MediaQuery.of(context).size.width,
                
                showActiveWaveform: true,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
          ),
        ],
      ),
    );
  }
}
