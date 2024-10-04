import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/data/datas.dart';
import 'package:readlexi/games/QuizAudio.dart';
import 'package:readlexi/games/QuizComPalabra.dart';
import 'package:readlexi/games/QuizTextyQues.dart';
import 'package:readlexi/games/TrueoFlase.dart';

class NivelsChooseView extends StatefulWidget {
  final PlanetInfo? planetInfo;

  // Constructor que acepta el nombre de la etapa
  const NivelsChooseView({this.planetInfo});

  @override
  State<NivelsChooseView> createState() => _NivelsChooseViewState();
}

class _NivelsChooseViewState extends State<NivelsChooseView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getNivelById(String id) async {
    print("inicio");
    DocumentSnapshot docSnapshot =
        await _firestore.collection('nivels').doc(id).get();
    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>?;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lexi Read"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popAndPushNamed(context, "/login");
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            // Mostramos el nombre de la etapa
            child: Text(
              "Etapa: ${widget.planetInfo?.name.toString()}",
              style: const TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columnas
              ),
              itemCount: 9, // 9 piezas de rompecabezas
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    print(((widget.planetInfo!.position.toInt() - 1) * 9) +
                        index +
                        1);
                    var idpregunta =
                        (((widget.planetInfo!.position.toInt() - 1) * 9) +
                            index +
                            1);
                    print("nivel");
                    var nivel = await _getNivelById('$idpregunta');
                    print(nivel?["tipo"]);
                    if (nivel?['tipo'] == "QuizPregunata") {
                      print(nivel);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            index: index + 1,
                            planetInfo: widget.planetInfo,
                            nivel: nivel,
                            question: nivel?["question"],
                            options: nivel?["options"],
                            correctAnswer: nivel?["correctAnswer"],
                          ),
                        ),
                      );
                    } else if (nivel?['tipo'] == "QuizTrueoFalse") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            index: index + 1,
                            planetInfo: widget.planetInfo,
                            nivel: nivel,
                            question: nivel?["question"],
                            options: nivel?["options"],
                            correctAnswer: nivel?["correctAnswer"],
                          ),
                        ),
                      );
                    } else if (nivel?['tipo'] == "QuizTextyQues") {
                      print(nivel);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizIntroPage(
                            index: index + 1,
                            planetInfo: widget.planetInfo,
                            nivel: nivel,
                            introText: nivel?["introText"],
                            buttonText: 'Let\'s Start',
                            quizData: nivel?["quizData"],
                          ),
                        ),
                      );
                    } else if (nivel?['tipo'] == "QuizComPalabra") {
                      print(nivel);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizComPala(
                            index: index + 1,
                            planetInfo: widget.planetInfo,
                            nivel: nivel,
                            letters: nivel?["letters"],
                            correctAnswer: nivel?["correctAnswer"],
                            questionText: nivel?["questionText"],
                            imageUrl: nivel?["imageUrl"],
                          ),
                        ),
                      );
                    } else if (nivel?['tipo'] == "QuizAudio") {
                      print(nivel);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimalSoundQuiz(
                            index: index + 1,
                            audioSource: nivel?["audioSource"],
                            options: nivel?["options"],
                            correctAnswer: nivel?["correctAnswer"],
                          ),
                        ),
                      );
                    }
                    // Redirigir a la nueva página cuando se presiona una pieza
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => PieceDetailPage(
                    //         index: index + 1, planetInfo: widget.planetInfo),
                    //   ),
                    // );
                  },
                  child: PuzzlePiece(
                    index: index,
                    planetInfo: widget.planetInfo,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PuzzlePiece extends StatelessWidget {
  final int index;
  final PlanetInfo? planetInfo;

  const PuzzlePiece({required this.index, required this.planetInfo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          CustomPaint(
            painter: PuzzlePiecePainter(index),
            child: Container(),
          ),
          // Agregar un número centrado en cada pieza
          Center(
            child: Text(
              "${index + 1}", // Mostrar números del 1 al 9
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PuzzlePiecePainter extends CustomPainter {
  final int index;

  PuzzlePiecePainter(this.index);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();

    // Dibujar bordes básicos
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Nueva pantalla para mostrar el detalle de la pieza
class PieceDetailPage extends StatefulWidget {
  final int index;
  final PlanetInfo? planetInfo;
  final Map<String, dynamic>? nivel;

  const PieceDetailPage(
      {super.key, required this.index, this.planetInfo, this.nivel});

  @override
  State<PieceDetailPage> createState() => _PieceDetailPageState();
}

class _PieceDetailPageState extends State<PieceDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de la Pieza"),
      ),
      body: Center(
        child: Text(
          "Estás viendo la pieza número ${widget.index} ${widget.planetInfo?.name.toString()}",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
