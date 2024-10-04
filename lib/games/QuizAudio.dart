import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AnimalSoundQuiz extends StatefulWidget {
  final int index;
  final String audioSource;
  final List<dynamic> options;
  final String correctAnswer;

  const AnimalSoundQuiz({
    super.key,
    required this.audioSource,
    required this.options,
    required this.correctAnswer,
    required this.index,
  });

  @override
  State<AnimalSoundQuiz> createState() => _AnimalSoundQuizState();
}

class _AnimalSoundQuizState extends State<AnimalSoundQuiz> {
  late AudioPlayer player;
  Duration? _duration;
  Duration? _position;
  bool _isPlaying = false;
  int? _selectedOptionIndex; // Guarda la opción seleccionada por el usuario

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
    await player.setSource(AssetSource("audio/${widget.audioSource}"));
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

  void _confirmAnswer() {
    if (_selectedOptionIndex != null) {
      bool isCorrect =
          widget.options[_selectedOptionIndex!] == widget.correctAnswer;
      _showResultDialog(isCorrect);
    }
  }

  Future<void> _showResultDialog(bool isCorrect) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? "¡Correcto!" : "Incorrecto"),
          content: Text(isCorrect
              ? "¡Has seleccionado la respuesta correcta!"
              : "La respuesta correcta era: ${widget.correctAnswer}."),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Animal Sound Quiz'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Identifica el sonido del animal.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_position != null ? _positionText() : '0:00'),
                Expanded(
                  child: Slider(
                    activeColor: Colors.pink,
                    value: sliderValue,
                    onChanged: (value) {
                      if (_duration != null) {
                        final newPosition = value * _duration!.inMilliseconds;
                        player
                            .seek(Duration(milliseconds: newPosition.round()));
                      }
                    },
                  ),
                ),
                Text(_duration != null ? _durationText() : '0:00'),
              ],
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              color: color,
              iconSize: 48,
              onPressed: _isPlaying ? _pause : _play,
            ),
            const SizedBox(height: 20),
            ..._buildOptionButtons(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex == null
                    ? null // Deshabilitar botón si no se seleccionó opción
                    : _confirmAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedOptionIndex == null
                      ? Colors.grey
                      : Colors.pink, // Cambia color según estado
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Confirmar respuesta',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionButtons() {
    return widget.options.asMap().entries.map<Widget>((entry) {
      int index = entry.key;
      String option = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedOptionIndex = index;
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _selectedOptionIndex == index
                ? Colors.blue[100]
                : Colors.grey[100],
            foregroundColor:
                _selectedOptionIndex == index ? Colors.blue : Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            option,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }).toList();
  }

  // Formato para mostrar el tiempo de posición
  String _positionText() {
    final minutes =
        _position!.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds =
        _position!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _durationText() {
    final minutes =
        _duration!.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds =
        _duration!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
