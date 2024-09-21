import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgeSelectionScreen extends StatefulWidget {
  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSaving = false; // Estado para saber si estamos guardando

  Future<void> _saveAgeToFirestore(String ageGroup) async {
    setState(() {
      _isSaving = true; // Muestra el indicador de guardado
    });

    // Obtener el usuario actual de FirebaseAuth
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // Guardar el rango de edad seleccionado en la colección 'users'
        await _firestore.collection('users').doc(currentUser.uid).update({
          'edad': ageGroup,
          'timestamp': FieldValue.serverTimestamp(),
        });

        Navigator.popAndPushNamed(context, "/home");
      } catch (e) {
        print('Error al guardar el rango de edad: $e');
      } finally {
        setState(() {
          _isSaving = false; // Ocultar el indicador de guardado
        });
      }
    } else {
      print('Usuario no autenticado');

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Lexi Read',
            style: TextStyle(
              color: Color.fromARGB(255, 88, 29, 29),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.popAndPushNamed(context, "/login");
                },
                icon: Icon(Icons.logout))
          ],
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: _isSaving
            ? Center(
                child:
                    CircularProgressIndicator()) // Indicador mientras se guarda
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        'Rango de Edad',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AgeCard(
                      ageRange: '4-11',
                      description: 'para niños de 4 a 11 años.',
                      onTap: () {
                        _saveAgeToFirestore('4-11');
                      },
                    ),
                    const SizedBox(height: 16),
                    AgeCard(
                      ageRange: '11-18',
                      description: 'para adolescentes',
                      onTap: () {
                        _saveAgeToFirestore('11-18');
                      },
                    ),
                    const SizedBox(height: 16),
                    AgeCard(
                      ageRange: '18-99',
                      description: 'para adultos de 18 a 99.',
                      onTap: () {
                        _saveAgeToFirestore('18-99');
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class AgeCard extends StatelessWidget {
  final String ageRange;
  final String description;
  final VoidCallback onTap;

  const AgeCard({
    required this.ageRange,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ocupar todo el ancho disponible
      child: InkWell(
        onTap: onTap, // Acción cuando se presiona la tarjeta
        borderRadius: BorderRadius.circular(16.0),
        splashColor: Colors.purple.withOpacity(0.2), // Efecto al tocar
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(
              color: Colors.black12,
            ),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  ageRange,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB58AFF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
