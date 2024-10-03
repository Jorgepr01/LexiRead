import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';

// class QuizApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Aquí pasamos una pregunta con sus opciones para mostrar en pantalla
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: QuizScreen(
//         question: '¿Meryl Streep ha ganado dos premios de la Academia?',
//         options: ['TRUE', 'FALSE'],
//       ),
//     );
//   }
// }

class QuizScreen extends StatefulWidget {
  final int index;
  final PlanetInfo? planetInfo;
  final Map<String, dynamic>? nivel;
  final String question; // Pregunta que se mostrará
  final List<dynamic> options; // Opciones de la pregunta

  QuizScreen(
      {required this.question,
      required this.options,
      required this.index,
      this.planetInfo,
      this.nivel}); // Constructor

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Acción al seleccionar una opción
  void selectOption(String option) {
    // Aquí puedes navegar a la siguiente pregunta, mostrar resultados, etc.
    print('Opción seleccionada: $option');
    // Puedes hacer la navegación a la siguiente pantalla con una nueva pregunta
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(0, 137, 7, 7),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            // Pregunta dinámica
            Text(
              widget.question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 50),
            // Botones de opciones dinámicas
            ...widget.options.map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    selectOption(option); // Acción al seleccionar la opción
                  },
                  child: Text(option, style: TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
