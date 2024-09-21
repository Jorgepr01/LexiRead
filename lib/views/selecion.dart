import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LexiReadHomePage extends StatefulWidget {
  const LexiReadHomePage({super.key});
  @override
  _LexiReadHomePageState createState() => _LexiReadHomePageState();
}

class _LexiReadHomePageState extends State<LexiReadHomePage> {
  // Valor seleccionado
  String _selectedPet = 'Gato';
  IconData _selectedPetIcon = Icons.pets; // Ícono por defecto

  // Lista de mascotas y sus íconos
  final Map<String, IconData> petOptions = {
    'Gato': Icons.pets,
    'Perro': Icons.pets,
    'Pájaro': Icons.flight,
    'Pez': Icons.pool,
  };

  void _changePet() {
    setState(() {
      // Ciclar a través de las opciones de mascotas
      final petList = petOptions.keys.toList();
      int currentIndex = petList.indexOf(_selectedPet);
      int nextIndex = (currentIndex + 1) % petList.length;
      _selectedPet = petList[nextIndex];
      _selectedPetIcon = petOptions[_selectedPet]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Imagen o logo en la parte superior
        const Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircleAvatar(
            radius: 135,
            backgroundImage: AssetImage('assets/images/Lexiread.png'),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        // Texto de bienvenida
        const Text(
          'Bienvenido',
          style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        const Text(
          'Felipe Hash',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),

        //niveles completados
        const Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Niveles completados\nNº 18',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),

        // Indicador de racha y otro ícono
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Column(
                children: [
                  Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 80),
                  Text('29'),
                ],
              ),
              const SizedBox(width: 70), // Espacio entre los íconos
              Column(
                children: [
                  GestureDetector(
                    onTap: _changePet, // Cambia la mascota al tocar el ícono
                    child:
                        Icon(_selectedPetIcon, color: Colors.black, size: 70),
                  ),
                  DropdownButton<String>(
                    value: _selectedPet, // Valor inicial
                    items: petOptions.keys.map((String pet) {
                      return DropdownMenuItem<String>(
                        value: pet,
                        child: Text(pet),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPet = newValue!;
                        _selectedPetIcon = petOptions[_selectedPet]!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
