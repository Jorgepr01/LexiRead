import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> obtenerEtapas() async {
  QuerySnapshot etapasSnapshot =
      await FirebaseFirestore.instance.collection('etapas').get();

  return etapasSnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
}

Future<List<Map<String, dynamic>>> obtenerNivelesPorEtapa(
    String etapaId) async {
  QuerySnapshot nivelesSnapshot = await FirebaseFirestore.instance
      .collection('niveles')
      .where('etapaId', isEqualTo: etapaId)
      .get();

  return nivelesSnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
}

Future<Map<String, dynamic>> obtenerProgresoUsuario(String uid) async {
  DocumentSnapshot<Map<String, dynamic>> usuarioSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

  // Verifica si el documento existe y si tiene el campo 'progreso'
  if (usuarioSnapshot.exists && usuarioSnapshot.data() != null) {
    return usuarioSnapshot.data()!['progreso'] ?? {};
  } else {
    return {}; // Retorna un mapa vacío si el documento no existe o no tiene el campo 'progreso'
  }
}

Future<void> mostrarProgreso(String uid, String etapaId) async {
  // 1. Obtener los niveles de la etapa
  List<Map<String, dynamic>> niveles = await obtenerNivelesPorEtapa(etapaId);

  // 2. Obtener el progreso del usuario
  Map<String, dynamic> progreso = await obtenerProgresoUsuario(uid);

  niveles.forEach((nivel) {
    String nivelId = nivel['id'];
    bool completado = progreso[etapaId]?[nivelId] ?? false;
    ('Nivel ${nivel['nombre']}: ${completado ? "Completado" : "No completado"}');
  });
}

Future<void> marcarNivelCompletado(
    String uid, String etapaId, String nivelId) async {
  DocumentReference usuarioRef =
      FirebaseFirestore.instance.collection('users').doc(uid);

  await usuarioRef.update({'progreso.$etapaId.$nivelId': true});
}
