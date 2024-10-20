import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VidasPage extends StatefulWidget {
  final String uid; // El ID del usuario
  VidasPage({required this.uid});

  @override
  _VidasPageState createState() => _VidasPageState();
}

class _VidasPageState extends State<VidasPage> {
  int vidas = 0; // Almacena las vidas actuales del usuario
  static const int VIDAS_MAXIMAS = 5;

  @override
  void initState() {
    super.initState();
    verificarYRestaurarVidas(widget.uid);
  }

  // Función para verificar y restaurar las vidas del usuario
  Future<void> verificarYRestaurarVidas(String uid) async {
    DocumentReference usuarioRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    DocumentSnapshot usuarioSnapshot = await usuarioRef.get();

    if (usuarioSnapshot.exists) {
      Map<String, dynamic> data =
          usuarioSnapshot.data() as Map<String, dynamic>;
      int vidasActuales = data['vidas'];

      // Si el campo `ultimaActualizacion` no existe, lo inicializamos
      Timestamp? ultimaActualizacion = data['ultimaActualizacion'];

      DateTime ahora = DateTime.now();

      // Si la última actualización no existe (usuario recién creado), inicializarla
      if (ultimaActualizacion == null) {
        await usuarioRef.update({
          'vidas': VIDAS_MAXIMAS,
          'ultimaActualizacion': Timestamp.now(),
        });
        setState(() {
          vidas = VIDAS_MAXIMAS;
        });
      } else {
        DateTime ultimaFecha = ultimaActualizacion.toDate();

        // Si han pasado más de 24 horas, restauramos las vidas
        if (ahora.difference(ultimaFecha).inHours >= 24) {
          await usuarioRef.update({
            'vidas': VIDAS_MAXIMAS,
            'ultimaActualizacion': Timestamp.now(),
          });
          vidasActuales = VIDAS_MAXIMAS;
        }

        setState(() {
          vidas = vidasActuales;
        });
      }
    } else {
      // Si el documento del usuario no existe, crearlo con valores por defecto
      await usuarioRef.set({
        'vidas': VIDAS_MAXIMAS,
        'ultimaActualizacion': Timestamp.now(),
      });

      setState(() {
        vidas = VIDAS_MAXIMAS;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tus vidas diarias'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Vidas disponibles:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              '$vidas',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await descontarVida(widget.uid);
              },
              child: Text('Usar una vida'),
            ),
          ],
        ),
      ),
    );
  }

  // Función para descontar una vida del usuario
  Future<void> descontarVida(String uid) async {
    DocumentReference usuarioRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    DocumentSnapshot usuarioSnapshot = await usuarioRef.get();
    if (usuarioSnapshot.exists) {
      Map<String, dynamic> data =
          usuarioSnapshot.data() as Map<String, dynamic>;
      int vidasActuales = data['vidas'];

      if (vidasActuales > 0) {
        await usuarioRef.update({
          'vidas': vidasActuales - 1,
        });

        setState(() {
          vidas = vidasActuales - 1;
        });

        print('Vida descontada. Vidas restantes: ${vidasActuales - 1}');
      } else {
        print('No tienes más vidas disponibles.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No tienes más vidas disponibles.'),
        ));
      }
    }
  }
}
