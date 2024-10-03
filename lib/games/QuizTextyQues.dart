import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Quiz App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: QuizIntroPage(
//         introText:
//             'Tesla es una compañía que produce autos eléctricos, paneles solares y soluciones de almacenamiento de energía. Fundada en 2003 por Elon Musk, la compañía rápidamente se ha convertido en un líder en la industria de vehículos eléctricos. Tesla es conocida por su tecnología innovadora, diseños elegantes y compromiso con la sostenibilidad.',
//         buttonText: 'Let\'s Start',
//         quizData: {
//           'question': 'What is Tesla\'s commitment to sustainability?',
//           'options': [
//             {'text': 'Using only coal as a power source', 'isCorrect': false},
//             {
//               'text':
//                   'Reducing its impact on the environment by using renewable energy sources',
//               'isCorrect': true
//             },
//             {'text': 'Building large-scale oil refineries', 'isCorrect': false},
//             {'text': 'Producing gasoline-powered cars', 'isCorrect': false},
//           ],
//         },
//       ),
//     );
//   }
// }

// Página de introducción
class QuizIntroPage extends StatelessWidget {
  final String introText;
  final String buttonText;
  final Map<String, dynamic> quizData;
  final int index;
  final PlanetInfo? planetInfo;
  final Map<String, dynamic>? nivel;

  QuizIntroPage({
    required this.introText,
    required this.buttonText,
    required this.quizData,
    required this.index,
    this.planetInfo,
    this.nivel,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la página de preguntas con datos dinámicos
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuizQuestionsPage(quizData: quizData),
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

  QuizQuestionsPage({required this.quizData});

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int? _selectedOptionIndex; // Guarda la opción seleccionada por el usuario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Quiz'),
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
                onPressed: _selectedOptionIndex == null
                    ? null // Deshabilitar el botón si no hay opción seleccionada
                    : () {
                        bool isCorrect = widget.quizData['options']
                            [_selectedOptionIndex!]['isCorrect'];
                        _showResultDialog(context, isCorrect);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedOptionIndex == null
                      ? Colors.grey // Deshabilitado
                      : Colors.pink, // Habilitado (color rosa original)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
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

  // Función para mostrar el diálogo de resultado
  void _showResultDialog(BuildContext context, bool isCorrect) {
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
