import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';

class QuizScreen extends StatefulWidget {
  final int index;
  final PlanetInfo? planetInfo;
  final Map<String, dynamic>? nivel;
  final String question; // Pregunta que se mostrará
  final List<dynamic> options; // Opciones de la pregunta
  final String correctAnswer; // Respuesta correcta

  const QuizScreen({
    required this.question,
    required this.options,
    required this.correctAnswer, // Agregado el parámetro correctAnswer
    required this.index,
    this.planetInfo,
    this.nivel,
    super.key,
  }); // Constructor

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedOptionIndex; // Índice de la opción seleccionada

  // Acción al seleccionar una opción
  void selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index; // Actualiza la opción seleccionada
    });
  }

  // Función para mostrar el resultado en un diálogo
  Future<void> _showResultDialog(bool isCorrect) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Vuelve atrás
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Pregunta dinámica
            Text(
              widget.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                    ? null // Deshabilitado si no se seleccionó una opción
                    : () {
                        String selectedOption = widget.options[
                            _selectedOptionIndex!]; // Opción seleccionada
                        bool isCorrect = selectedOption ==
                            widget.correctAnswer; // Verificación
                        _showResultDialog(isCorrect);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedOptionIndex == null
                      ? Colors.grey
                      : Colors.pink, // Color si está habilitado o no
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

  // Construir los botones de opciones
  List<Widget> _buildOptionButtons() {
    return widget.options.asMap().entries.map<Widget>((entry) {
      int index = entry.key;
      String option = entry.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () {
            selectOption(index); // Seleccionar opción
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _selectedOptionIndex == index
                ? Colors.blue[100]
                : Colors.grey[100], // Color de fondo si está seleccionada
            foregroundColor: _selectedOptionIndex == index
                ? Colors.blue
                : Colors.black87, // Color del texto si está seleccionada
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
