import 'package:cloud_firestore/cloud_firestore.dart';

class PlanetInfo {
  final int position;
  final String? name;
  final String? iconImage;

  PlanetInfo(
    this.position, {
    this.name,
    this.iconImage,
  });

  // Factory para crear un PlanetInfo desde un documento de Firestore
  factory PlanetInfo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlanetInfo(
      data['position'],
      name: data['name'],
      iconImage: data['iconImage'],
    );
  }
}
