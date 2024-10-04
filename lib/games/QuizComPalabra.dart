import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';

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
  void checkAnswer() {
    String userAnswer = selectedLetters.join();
    bool isCorrect = userAnswer == widget.correctAnswer;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "¡Correcto!" : "Incorrecto"),
        content: Text(
            isCorrect ? "Has adivinado correctamente." : "Intenta de nuevo."),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Car Quiz"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
            const SizedBox(height: 20),
            // Imagen
            Image.asset(
              "assets/${widget.imageUrl}",
              height: 100,
            ),
            const SizedBox(height: 30),
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
                onPressed: checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
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
            // SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
