import 'package:flutter/material.dart';

// Widget personalizado del BottomNavigationBar
class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavigationWidget({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Índice de la pestaña seleccionada
      onTap: onTap, // Llama a la función onTap cuando se toca un ítem
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videogame_asset),
          label: 'Juego',
        ),
      ],
    );
  }
}
