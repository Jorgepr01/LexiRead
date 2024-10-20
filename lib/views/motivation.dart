import 'package:flutter/material.dart';

class MotivationalMessagesPage extends StatelessWidget {
  final List<String> messages = [
    "Cree en ti mismo",
    "El esfuerzo trae recompensa",
    "Nunca es tarde para aprender",
    "Haz lo que amas y nunca tendrás que trabajar",
    "La perseverancia es clave para alcanzar tus metas más ambiciosas",
    "Cree en ti mismo",
    "El esfuerzo trae recompensa",
    "Nunca es tarde para aprender",
    "Haz lo que amas y nunca tendrás que trabajar",
    "La perseverancia es clave para alcanzar tus metas más ambiciosas",
  ];

  final List<IconData> icons = [
    Icons.thumb_up_alt_outlined,
    Icons.star_outline,
    Icons.school_outlined,
    Icons.favorite_outline,
    Icons.trending_up_outlined,
    Icons.thumb_up_alt_outlined,
    Icons.star_outline,
    Icons.school_outlined,
    Icons.favorite_outline,
    Icons.trending_up_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: List.generate(messages.length, (index) {
              bool isEven = index % 2 == 0;
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 20.0), // Espaciado entre las tarjetas
                child: Row(
                  mainAxisAlignment:
                      isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    if (isEven)
                      _buildIcon(
                          icons[index]), // Ícono a la izquierda si es par
                    Expanded(
                        child: _buildMessageCard(messages[
                            index])), // Expande el Card para evitar overflow
                    if (!isEven)
                      _buildIcon(
                          icons[index]), // Ícono a la derecha si es impar
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(icon, color: Colors.green, size: 40),
    );
  }

  Widget _buildMessageCard(String message) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          softWrap: true, // Permite que el texto se ajuste
        ),
      ),
    );
  }
}
