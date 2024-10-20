import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/utils/logUser.dart';

class AnimalSoundQuiz extends StatefulWidget {
  final int index;
  final String audioSource;
  final List<dynamic> options;
  final String correctAnswer;
  final int vidasIniciales;
  final Map<String, dynamic>? nivel;

  const AnimalSoundQuiz({
    super.key,
    required this.audioSource,
    required this.options,
    required this.correctAnswer,
    required this.index,
    required this.vidasIniciales,
    this.nivel, // Inicializar vidas
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
  late int vidas; // Se inicializa con el valor de vidasIniciales

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    vidas = widget.vidasIniciales; // Asignamos las vidas iniciales al inicio

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

  void _confirmAnswer() async {
    if (_selectedOptionIndex != null) {
      bool isCorrect =
          widget.options[_selectedOptionIndex!] == widget.correctAnswer;

      // Si es incorrecto, restamos una vida
      final UserService _userService = UserService();
      var userData = await _userService.getUserData();
      if (!isCorrect) {
        await descontarVida(userData?["uid"]);
        setState(() {
          vidas -= 1;
        });
      } else {
        marcarNivelCompletado(userData?["uid"], "${widget.nivel?["etapaId"]}",
            "${widget.nivel?["id"]}");
      }

      _showResultDialog(isCorrect);

      // Si se queda sin vidas, mostrar diálogo de "sin vidas"
      if (vidas == 0 && !isCorrect) {
        _showNoLivesDialog();
      }
    }
  }

  Future<void> marcarNivelCompletado(
      String uid, String etapaId, String nivelId) async {
    DocumentReference usuarioRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    await usuarioRef.update({'progreso.$etapaId.$nivelId': true});
  }

  Future<void> descontarVida(String uid) async {
    DocumentReference usuarioRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    DocumentSnapshot usuarioSnapshot = await usuarioRef.get();
    if (usuarioSnapshot.exists) {
      Map<String, dynamic> data =
          usuarioSnapshot.data() as Map<String, dynamic>;
      int vidasActuales = data['vidas'];
      await usuarioRef.update({
        'vidas': vidasActuales - 1,
      });
      print('Vida descontada. Vidas restantes: ${vidasActuales - 1}');
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

  // Diálogo para mostrar cuando se quedan sin vidas
  Future<void> _showNoLivesDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Sin vidas!'),
        content: const Text('No tienes más vidas disponibles.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar corazones según el número de vidas restantes
  Widget _buildVidas() {
    List<Widget> hearts = [];
    for (int i = 0; i < widget.vidasIniciales; i++) {
      hearts.add(Icon(
        i < vidas
            ? Icons.favorite
            : Icons.favorite_border, // Corazón lleno o vacío
        color: Colors.red,
        size: 24,
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: hearts,
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
        title: Text("Quiz"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Agregamos los íconos de corazones al AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildVidas(),
          ),
        ],
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
                onPressed: _selectedOptionIndex == null || vidas == 0
                    ? null // Deshabilitar botón si no se seleccionó opción o no hay vidas
                    : _confirmAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedOptionIndex == null || vidas == 0
                      ? Colors.grey // Deshabilitar si no hay opción o vidas
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
