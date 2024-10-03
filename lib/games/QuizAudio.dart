import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';

// void main() {
//   runApp(const MaterialApp(
//     home: AnimalSoundQuiz(
//       audioSource: 'assets/animal_sound.mp3',
//       options: ['Lion', 'Elephant', 'Dog', 'Cat'],
//       correctAnswer: 'Dog',
//     ),
//   ));
// }

class AnimalSoundQuiz extends StatefulWidget {
  final int index;
  final PlanetInfo? planetInfo;
  final Map<String, dynamic>? nivel;
  final String audioSource;
  final List<dynamic> options;
  final String correctAnswer;

  const AnimalSoundQuiz({
    super.key,
    required this.audioSource,
    required this.options,
    required this.correctAnswer,
    required this.index,
    this.planetInfo,
    this.nivel,
  });

  @override
  State<AnimalSoundQuiz> createState() => _AnimalSoundQuizState();
}

class _AnimalSoundQuizState extends State<AnimalSoundQuiz> {
  late AudioPlayer player;
  Duration? _duration;
  Duration? _position;
  bool _isPlaying = false;
  String selectedOption = "";

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);

    player.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });

    player.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await player.setSource(AssetSource(widget.audioSource));
    await player.resume();
  }

  Future<void> _pause() async {
    await player.pause();
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  void _confirmAnswer() {
    if (selectedOption.isNotEmpty) {
      bool isCorrect = selectedOption == widget.correctAnswer;
      _showResultDialog(isCorrect);
    }
  }

  Future<void> _showResultDialog(bool isCorrect) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? "Correct!" : "Incorrect"),
          content: Text(isCorrect
              ? "You selected the right answer."
              : "The correct answer was: ${widget.correctAnswer}."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final double sliderValue = (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0)
        ? _position!.inMilliseconds / (_duration!.inMilliseconds)
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Animal Sound Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Identify an animal based on its sound.",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Slider and audio controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_position != null ? _positionText() : '0s'),
                Expanded(
                  child: Slider(
                    activeColor: Colors.pink,
                    value: sliderValue,
                    onChanged: (value) {
                      final newPosition = value * _duration!.inMilliseconds;
                      player.seek(Duration(milliseconds: newPosition.round()));
                    },
                  ),
                ),
                Text(_duration != null ? _durationText() : '0s'),
              ],
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              color: color,
              iconSize: 48,
              onPressed: _isPlaying ? _pause : _play,
            ),
            const SizedBox(height: 20),
            // Options buttons
            Expanded(
              child: ListView.builder(
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  return _buildOptionButton(widget.options[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            // Confirm Answer Button
            ElevatedButton(
              onPressed: selectedOption.isNotEmpty ? _confirmAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child:
                  const Text("Confirm Answer", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions for formatting
  String _positionText() {
    final minutes =
        _position!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _position!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _durationText() {
    final minutes =
        _duration!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _duration!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Option Button Builder
  Widget _buildOptionButton(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor:
              selectedOption == option ? Colors.pink : Colors.white,
          foregroundColor:
              selectedOption == option ? Colors.white : Colors.black,
        ),
        onPressed: () => _selectOption(option),
        child: Text(option, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
