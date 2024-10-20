import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';
import 'package:readlexi/utils/logUser.dart';

// Página de introducción
class QuizIntroPage extends StatelessWidget {
  final String introText;
  final String buttonText;
  final Map<String, dynamic> quizData;
  final int index;
  final PlanetInfo? planetInfo;
  final Map<String, dynamic>? nivel;
  final int vidasIniciales; // Definir número de vidas iniciales
  final String imagen;

  QuizIntroPage({
    required this.introText,
    required this.buttonText,
    required this.quizData,
    required this.index,
    this.planetInfo,
    this.nivel,
    required this.vidasIniciales,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('About Tesla'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                introText,
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.justify,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.asset(
                "assets/question/$imagen", // Muestra la imagen
                height: 250,
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la página de preguntas con datos dinámicos
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizQuestionsPage(
                          nivel: nivel,
                          quizData: quizData,
                          vidasIniciales:
                              vidasIniciales), // Pasamos 3 vidas iniciales
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  buttonText,
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

// Página de preguntas del quiz
class QuizQuestionsPage extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final int vidasIniciales; // Definir número de vidas iniciales
  final Map<String, dynamic>? nivel;

  QuizQuestionsPage(
      {required this.quizData,
      required this.vidasIniciales,
      this.nivel}); // Recibir el número de vidas iniciales

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int? _selectedOptionIndex; // Guarda la opción seleccionada por el usuario
  late int vidas; // Vidas que se inicializan según el parámetro recibido

  @override
  void initState() {
    super.initState();
    vidas = widget
        .vidasIniciales; // Inicializar las vidas al valor pasado por el parámetro
  }

  // Función para mostrar corazones en el AppBar
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quiz'), // Título del AppBar
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildVidas(), // Mostrar los corazones en el AppBar
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.quizData['question'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ..._buildOptionButtons(),
            Spacer(), // Espaciador para empujar el botón hacia abajo
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex == null || vidas == 0
                    ? null // Deshabilitar el botón si no hay opción seleccionada o no tiene vidas
                    : () {
                        bool isCorrect = widget.quizData['options']
                            [_selectedOptionIndex!]['isCorrect'];

                        // Si es incorrecto, reducir una vida
                        if (!isCorrect) {
                          setState(() {
                            vidas -= 1;
                          });
                        }

                        _showResultDialog(context, isCorrect);

                        // Mostrar diálogo si no tiene más vidas
                        if (vidas == 0 && !isCorrect) {
                          _showNoLivesDialog();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedOptionIndex == null || vidas == 0
                      ? Colors.grey // Deshabilitado si no hay opción o vidas
                      : Colors.pink, // Habilitado (color rosa original)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  vidas == 0
                      ? 'Sin vidas'
                      : 'Confirmar respuesta', // Mostrar "Sin vidas" si se quedan sin vidas
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo cuando el usuario se queda sin vidas
  Future<void> _showNoLivesDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Sin vidas!'),
          content: Text('No tienes más vidas disponibles.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildOptionButtons() {
    return widget.quizData['options'].asMap().entries.map<Widget>((entry) {
      int index = entry.key;
      Map<String, dynamic> option = entry.value;
      return OptionButton(
        text: option['text'],
        isSelected: _selectedOptionIndex == index,
        onPressed: () {
          setState(() {
            _selectedOptionIndex = index;
          });
        },
      );
    }).toList();
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

  // Función para mostrar el diálogo de resultado
  void _showResultDialog(BuildContext context, bool isCorrect) async {
    final UserService _userService = UserService();
    var userData = await _userService.getUserData();
    if (!isCorrect) {
      await descontarVida(userData?["uid"]);
    } else {
      marcarNivelCompletado(userData?["uid"], "${widget.nivel?["etapaId"]}",
          "${widget.nivel?["id"]}");
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? '¡Correcto!' : 'Incorrecto'),
          content: Text(isCorrect
              ? '¡Has seleccionado la respuesta correcta!'
              : 'La respuesta seleccionada es incorrecta.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Widget para cada botón de opción
class OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  OptionButton(
      {required this.text, required this.isSelected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isSelected ? Colors.blue[100] : Colors.grey[100],
          foregroundColor: isSelected ? Colors.blue : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
