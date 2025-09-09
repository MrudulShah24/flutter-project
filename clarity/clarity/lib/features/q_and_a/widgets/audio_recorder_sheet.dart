import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderSheet extends StatefulWidget {
  const AudioRecorderSheet({super.key});

  @override
  State<AudioRecorderSheet> createState() => _AudioRecorderSheetState();
}

class _AudioRecorderSheetState extends State<AudioRecorderSheet> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: filePath);
      setState(() {
        _isRecording = true;
        _audioPath = filePath;
        _recordDuration = 0;
      });
      _startTimer();
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });
    if (mounted && path != null) {
      Navigator.pop(context, path);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isRecording ? "Recording..." : "Record Audio",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text(_formatDuration(_recordDuration), style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 20),
          if (_audioPath == null)
            ElevatedButton.icon(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? "Stop" : "Start Recording"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
              ),
            ),
          if (_audioPath != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(onPressed: () => setState(() {
                  _audioPath = null;
                  _recordDuration = 0;
                }), child: const Text("Retake")),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _audioPath),
                  child: const Text("Attach"),
                ),
              ],
            )
        ],
      ),
    );
  }
}