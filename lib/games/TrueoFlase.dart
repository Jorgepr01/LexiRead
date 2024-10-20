import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';
import 'package:readlexi/utils/logUser.dart';

class QuizScreen extends StatefulWidget {
  final int index;
  final String question; // Pregunta que se mostrará
  final List<dynamic> options; // Opciones de la pregunta
  final String correctAnswer; // Respuesta correcta
  final String imageName; // Nombre de la imagen
  final int vidasIniciales; // Vidas iniciales como parámetro
  final Map<String, dynamic>? nivel;

  const QuizScreen({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.index,
    required this.imageName, // Parámetro para la imagen
    required this.vidasIniciales, // Parámetro para las vidas iniciales
    super.key,
    required PlanetInfo planetInfo,
    this.nivel,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late int vidas; // Número de vidas actuales
  int? _selectedOptionIndex; // Índice de la opción seleccionada

  @override
  void initState() {
    super.initState();
    vidas =
        widget.vidasIniciales; // Inicializar las vidas al valor del parámetro
  }

  // Función para mostrar los íconos de corazones en el AppBar
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

  void selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  Future<void> _showResultDialog(bool isCorrect) async {
    final UserService _userService = UserService();
    var userData = await _userService.getUserData();
    if (!isCorrect) {
      await descontarVida(userData?["uid"]);
    } else {
      marcarNivelCompletado(userData?["uid"], "${widget.nivel?["etapaId"]}",
          "${widget.nivel?["id"]}");
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? '¡Correcto!' : 'Incorrecto'),
          content: Text(isCorrect
              ? '¡Has seleccionado la respuesta correcta!'
              : 'La respuesta correcta era: ${widget.correctAnswer}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNoLivesDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Sin vidas!'),
          content: const Text('No tienes más vidas disponibles.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Quiz"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildVidas(), // Mostrar los corazones en el AppBar
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pregunta dinámica
            Text(
              widget.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Imagen dinámica
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                "assets/question/${widget.imageName}", // Muestra la imagen
                height: 250,
              ),
            ),
            const SizedBox(height: 20),
            // Botones de opciones dinámicas
            ..._buildOptionButtons(),
            const Spacer(),
            // Botón para confirmar la respuesta
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex == null
                    ? null
                    : () {
                        if (vidas > 0) {
                          String selectedOption =
                              widget.options[_selectedOptionIndex!];
                          bool isCorrect =
                              selectedOption == widget.correctAnswer;

                          if (!isCorrect) {
                            setState(() {
                              vidas -=
                                  1; // Reducir vidas si la respuesta es incorrecta
                            });
                          }

                          _showResultDialog(isCorrect);
                        } else {
                          _showNoLivesDialog(); // Mostrar el diálogo de "sin vidas"
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedOptionIndex == null ? Colors.grey : Colors.pink,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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

  List<Widget> _buildOptionButtons() {
    return widget.options.asMap().entries.map<Widget>((entry) {
      int index = entry.key;
      String option = entry.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () {
            selectOption(index);
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
}
