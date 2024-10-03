import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Pasamos los parámetros de letras y la respuesta correcta
//     return MaterialApp(
//       home: QuizComPala(
//         letters: ['E', 'V', 'H', 'C', 'E', 'O', 'R', 'T'],
//         correctAnswer: "CHEVROET",
//         questionText:
//             '¿Cuál es el nombre del fabricante estadounidense de autos conocido por el Camaro y el Corvette?',
//         imageUrl:
//             'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Chevrolet_logo_%282013%29.png/600px-Chevrolet_logo_%282013%29.png',
//       ),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

class QuizComPala extends StatefulWidget {
  final int index;
  final PlanetInfo? planetInfo;
  final Map<String, dynamic>? nivel;
  final List<dynamic> letters;
  final String correctAnswer;
  final String questionText;
  final String imageUrl;

  QuizComPala({
    required this.letters,
    required this.correctAnswer,
    required this.questionText,
    required this.imageUrl,
    required this.index,
    this.planetInfo,
    this.nivel,
  });

  @override
  _QuizComPalaState createState() => _QuizComPalaState();
}

class _QuizComPalaState extends State<QuizComPala> {
  late List<String> selectedLetters;
  late List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    selectedLetters = [];
    isSelected = List.generate(widget.letters.length, (index) => false);
  }

  // Función para seleccionar o deseleccionar letras
  void toggleLetter(String letter, int index) {
    setState(() {
      if (isSelected[index]) {
        // Si ya está seleccionada, la removemos de la selección
        selectedLetters.remove(letter);
        isSelected[index] = false;
      } else {
        // Si no está seleccionada, la agregamos
        if (selectedLetters.length < widget.correctAnswer.length) {
          selectedLetters.add(letter);
          isSelected[index] = true;
        }
      }
    });
  }

  // Función para verificar la respuesta
  void checkAnswer() {
    String userAnswer = selectedLetters.join();
    if (userAnswer == widget.correctAnswer) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("¡Correcto!"),
          content: Text("Has adivinado correctamente."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Incorrecto"),
          content: Text("Intenta de nuevo."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    }
  }

  // Función para resetear el quiz
  void resetQuiz() {
    setState(() {
      selectedLetters.clear();
      isSelected = List.generate(widget.letters.length, (index) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Car Quiz"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetQuiz,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              widget.questionText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Imagen
            // Image.network(
            //   "assets/${widget.imageUrl}",
            //   height: 100,
            // ),
            Image.asset(
              "assets/${widget.imageUrl}",
              height: 100,
            ),
            SizedBox(height: 30),
            // Espacios para la respuesta
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.correctAnswer.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 40,
                  width: 30,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 2)),
                  ),
                  child: Center(
                    child: Text(
                      selectedLetters.length > index
                          ? selectedLetters[index]
                          : '',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            // Letras para seleccionar
            Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(widget.letters.length, (index) {
                return GestureDetector(
                  onTap: () {
                    toggleLetter(widget.letters[index], index);
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected[index]
                          ? Colors.grey[300]
                          : Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueGrey),
                    ),
                    child: Center(
                      child: Text(
                        widget.letters[index],
                        style: TextStyle(
                          fontSize: 24,
                          color:
                              isSelected[index] ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 30),
            // Botón de enviar respuesta
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text("Enviar"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.pink,
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
