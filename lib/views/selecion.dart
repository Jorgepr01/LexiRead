import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/utils/logUser.dart';

class LexiReadHomePage extends StatefulWidget {
  const LexiReadHomePage({super.key});

  @override
  _LexiReadHomePageState createState() => _LexiReadHomePageState();
}

class _LexiReadHomePageState extends State<LexiReadHomePage> {
  final UserService _userService = UserService();
  String _selectedPet = 'Cargando...';
  IconData _selectedPetIcon = Icons.pets; // Ícono por defecto
  String username = 'Cargando...';
  int completedLevels = 0;
  int racha = 0; // Variable para almacenar la racha del usuario
  var email, edad, uid;

  // Lista dinámica para mascotas
  List<Map<String, dynamic>> petOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    var userData = await _userService.getUserData();
    if (userData != null) {
      setState(() {
        username = userData['name'];
        email = userData['email'];
        edad = userData['edad'];
        uid = userData['uid'];
      });

      // Después de cargar los datos del usuario, cargamos los petOptions
      _fetchPetOptions(uid);
      contarNivelesCompletados(uid);
      verificarYRestaurarVidas(uid);
      // _verificarYActualizarRacha(uid); // Verificar y actualizar la racha
    }
  }

  // Método para verificar y actualizar la racha del usuario
  // Future<void> _verificarYActualizarRacha(String uid) async {
  //   try {
  //     DocumentSnapshot userSnapshot =
  //         await FirebaseFirestore.instance.collection('users').doc(uid).get();

  //     if (userSnapshot.exists) {
  //       Map<String, dynamic> userData =
  //           userSnapshot.data() as Map<String, dynamic>;

  //       int rachaActual =
  //           userData['racha'] ?? 0; // Valor por defecto 0 si no existe
  //       Timestamp? ultimaActualizacion = userData['ultimaActualizacion'];

  //       DateTime ahora = DateTime.now();
  //       DateTime? ultimaFecha = ultimaActualizacion?.toDate();

  //       if (ultimaFecha != null) {
  //         Duration diferencia = ahora.difference(ultimaFecha);

  //         // Si la diferencia es mayor o igual a 24 horas, incrementamos la racha
  //         if (diferencia.inHours >= 24 && diferencia.inHours <= 48) {
  //           rachaActual += 1;
  //           print('Racha incrementada a $rachaActual');
  //         } else {
  //           rachaActual = 1;
  //           print('Iniciando racha a 1');
  //         }
  //       } else {
  //         // Si no hay última actualización, empezamos la racha
  //         rachaActual = 1;
  //         print('Iniciando racha a 1');
  //       }

  //       // Actualizamos Firestore solo si se ha pasado un nuevo día
  //       if (ultimaFecha == null ||
  //           (ahora.difference(ultimaFecha).inHours >= 24 &&
  //               ahora.difference(ultimaFecha).inHours <= 48) ||
  //           rachaActual == 1) {
  //         await FirebaseFirestore.instance.collection('users').doc(uid).update({
  //           'racha': rachaActual,
  //           'ultimaActualizacion': Timestamp.now(),
  //         });
  //       }

  //       // Actualizamos el estado para reflejar los cambios en la UI
  //       setState(() {
  //         racha = rachaActual;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error al verificar y actualizar la racha: $e');
  //   }
  // }

  Future<void> verificarYRestaurarVidas(String uid) async {
    print("verificando corazones");
    const int VIDAS_MAXIMAS = 5;

    DocumentReference usuarioRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    DocumentSnapshot usuarioSnapshot = await usuarioRef.get();

    if (usuarioSnapshot.exists) {
      // El documento del usuario existe, verificamos los campos
      Map<String, dynamic> data =
          usuarioSnapshot.data() as Map<String, dynamic>;
      int? vidasActuales = data['vidas'];
      int rachaActual = data['racha'] ?? 0; // Valor por defecto 0 si no existe
      Timestamp? ultimaActualizacion = data['ultimaActualizacion'];
      print(vidasActuales);
      print(ultimaActualizacion);
      if (vidasActuales == null ||
          ultimaActualizacion == null ||
          rachaActual == 0) {
        rachaActual += 1;
        await usuarioRef.update({
          'racha': rachaActual,
          'vidas': VIDAS_MAXIMAS, // Inicializamos con el número máximo de vidas
          'ultimaActualizacion': Timestamp.now(), // Registramos la fecha actual
        });
        print("inicialiaznso las vidas de usuario");
        return;
      } else {
        DateTime ahora = DateTime.now();
        DateTime? ultimaFecha = ultimaActualizacion!.toDate();
        // Si han pasado más de 24 horas, restauramos las vidas
        if (ahora.difference(ultimaFecha).inHours >= 24 &&
            ahora.difference(ultimaFecha).inHours <= 48) {
          rachaActual += 1;
          print("racha: $rachaActual");
          await usuarioRef.update({
            'racha': rachaActual,
            'vidas': VIDAS_MAXIMAS,
            'ultimaActualizacion': Timestamp.now(),
          });
          print('Vidas restauradas a $VIDAS_MAXIMAS');
        } else if (ahora.difference(ultimaFecha).inHours >= 24) {
          rachaActual = 1;
          await usuarioRef.update({
            'racha': rachaActual,
            'vidas': VIDAS_MAXIMAS,
            'ultimaActualizacion': Timestamp.now(),
          });
        } else {
          print('Vidas actuales: $vidasActuales');
        }
        setState(() {
          racha = rachaActual;
        });
      }
    } else {
      // Si el documento del usuario no existe (es un usuario nuevo), crearlo con valores por defecto
      await usuarioRef.update({
        'vidas': VIDAS_MAXIMAS, // Inicializamos con el número máximo de vidas
        'ultimaActualizacion': Timestamp.now(), // Registramos la fecha actual
      });
      print('Usuario creado con $VIDAS_MAXIMAS vidas');
    }
  }

  // Método para obtener petOptions desde el campo del documento de usuario
  Future<void> _fetchPetOptions(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        if (userData.containsKey('petOptions')) {
          List<dynamic> pets = userData['petOptions'];
          setState(() {
            petOptions = pets.cast<Map<String, dynamic>>(); // Cast a la lista
            if (petOptions.isNotEmpty) {
              // Establecer la primera opción por defecto
              _selectedPet = petOptions[0]['nombre'];
              _selectedPetIcon = _getIconDataFromString(petOptions[0]['icon']);
            }
          });
        }
      }
    } catch (e) {
      print('Error al obtener petOptions: $e');
    }
  }

  // Método para contar los niveles completados
  Future<void> contarNivelesCompletados(String uid) async {
    DocumentSnapshot usuarioSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    print(uid);
    Map<String, dynamic> data = usuarioSnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> progreso = data['progreso'] as Map<String, dynamic>;

    int totalCompletados = 0;
    progreso.forEach((etapaId, niveles) {
      totalCompletados += (niveles as Map<String, dynamic>)
          .values
          .where((completado) => completado == true)
          .length;
    });

    setState(() {
      completedLevels = totalCompletados;
    });
  }

  // Convierte un string de Firestore en un IconData
  IconData _getIconDataFromString(String iconString) {
    switch (iconString) {
      case 'pets':
        return Icons.pets;
      case 'pool':
        return Icons.pool;
      case 'flight':
        return Icons.flight;
      default:
        return Icons.pets; // Icono por defecto
    }
  }

  // Cambiar la mascota seleccionada
  void _changePet() {
    setState(() {
      final currentIndex =
          petOptions.indexWhere((pet) => pet['nombre'] == _selectedPet);
      final nextIndex = (currentIndex + 1) % petOptions.length;
      _selectedPet = petOptions[nextIndex]['nombre'];
      _selectedPetIcon = _getIconDataFromString(petOptions[nextIndex]['icon']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: CircleAvatar(
            radius: 135,
            backgroundImage: AssetImage('assets/images/Lexiread.png'),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Bienvenido',
          style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          username,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Niveles completados\nNº $completedLevels',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 80),
                  Text('$racha', // Mostrar la racha obtenida de Firebase
                      style: const TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(width: 70),
              Column(
                children: [
                  GestureDetector(
                    onTap: _changePet,
                    child:
                        Icon(_selectedPetIcon, color: Colors.black, size: 70),
                  ),
                  if (petOptions.isNotEmpty)
                    DropdownButton<String>(
                      value: _selectedPet,
                      items: petOptions.map((pet) {
                        return DropdownMenuItem<String>(
                          value: pet['nombre'],
                          child: Text(pet['nombre']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPet = newValue!;
                          final selectedPet = petOptions
                              .firstWhere((pet) => pet['nombre'] == newValue);
                          _selectedPetIcon =
                              _getIconDataFromString(selectedPet['icon']);
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
