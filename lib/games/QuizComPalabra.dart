import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';
import 'package:readlexi/utils/logUser.dart';

class QuizComPala extends StatefulWidget {
  final int index;
  final PlanetInfo? planetInfo;
  final Map<String, dynamic>? nivel;
  final List<dynamic> letters;
  final String correctAnswer;
  final String questionText;
  final String imageUrl;
  final int vidasIniciales; // Nuevo parámetro para definir las vidas iniciales

  QuizComPala({
    required this.letters,
    required this.correctAnswer,
    required this.questionText,
    required this.imageUrl,
    required this.index,
    this.planetInfo,
    this.nivel,
    required this.vidasIniciales, // Inicializamos con un número de vidas personalizado
  });

  @override
  _QuizComPalaState createState() => _QuizComPalaState();
}

class _QuizComPalaState extends State<QuizComPala> {
  late List<String> selectedLetters;
  late List<bool> isSelected;
  late int vidas; // Vidas, se inicializan con el valor de `vidasIniciales`

  @override
  void initState() {
    super.initState();
    selectedLetters = [];
    isSelected = List.generate(widget.letters.length, (index) => false);
    vidas = widget.vidasIniciales; // Asignamos el valor de las vidas iniciales
  }

  // Función para seleccionar o deseleccionar letras
  void toggleLetter(String letter, int index) {
    setState(() {
      if (isSelected[index]) {
        selectedLetters.remove(letter);
        isSelected[index] = false;
      } else {
        if (selectedLetters.length < widget.correctAnswer.length) {
          selectedLetters.add(letter);
          isSelected[index] = true;
        }
      }
    });
  }

  // Función para verificar la respuesta
  void checkAnswer() async {
    String userAnswer = selectedLetters.join();
    bool isCorrect = userAnswer == widget.correctAnswer;
    final UserService _userService = UserService();
    var userData = await _userService.getUserData();
    if (!isCorrect) {
      await descontarVida(userData?["uid"]);
    } else {
      marcarNivelCompletado(userData?["uid"], "${widget.nivel?["etapaId"]}",
          "${widget.nivel?["id"]}");
    }
    if (!isCorrect) {
      setState(() {
        vidas -= 1; // Restamos una vida si la respuesta es incorrecta
      });
    }

    // Mostrar el diálogo correspondiente
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "¡Correcto!" : "Incorrecto"),
        content: Text(isCorrect
            ? "Has adivinado correctamente."
            : vidas > 0
                ? "Intenta de nuevo."
                : "Te has quedado sin vidas."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );

    // Si el usuario se queda sin vidas, mostramos un diálogo adicional
    if (vidas == 0) {
      _showNoLivesDialog();
    }
  }

  // Función para mostrar un mensaje cuando se queda sin vidas
  Future<void> _showNoLivesDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('¡Sin vidas!'),
        content: Text('No tienes más vidas disponibles.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // Widget para mostrar los corazones en función del número de vidas restantes
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

  // Función para resetear el quiz
  void resetQuiz() {
    setState(() {
      selectedLetters.clear();
      isSelected = List.generate(widget.letters.length, (index) => false);
      vidas = widget.vidasIniciales; // Restablecemos las vidas al valor inicial
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Quiz"),
        // centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Agregamos los íconos de corazones al AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildVidas(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetQuiz,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Texto de la pregunta
            Text(
              widget.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.asset(
                "assets/question/${widget.imageUrl}", // Muestra la imagen
                height: 250,
              ),
            ),
            // Image.asset(
            //     "assets/question/${widget.imageUrl}", // Muestra la imagen
            //     height: 250,
            //   ),
            // Espacios para la respuesta
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.correctAnswer.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 40,
                  width: 30,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(width: 2)),
                  ),
                  child: Center(
                    child: Text(
                      selectedLetters.length > index
                          ? selectedLetters[index]
                          : '',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Letras para seleccionar
            Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(widget.letters.length, (index) {
                return GestureDetector(
                  onTap: () {
                    toggleLetter(widget.letters[index], index);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected[index]
                          ? Colors.blue[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueGrey),
                    ),
                    child: Center(
                      child: Text(
                        widget.letters[index],
                        style: TextStyle(
                          fontSize: 24,
                          color: isSelected[index] ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Spacer(),
            // Botón de enviar respuesta
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: vidas > 0 // Deshabilitamos el botón si no hay vidas
                    ? checkAnswer
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: vidas > 0
                      ? Colors.pink
                      : Colors.grey, // Cambiar el color si no hay vidas
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Enviar",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
