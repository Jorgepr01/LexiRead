import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUserGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Iniciar sesión con Google
  Future<User?> loginGoogleA() async {
    try {
      final GoogleSignInAccount? accountGoogle = await GoogleSignIn().signIn();
      if (accountGoogle == null) {
        return null; // El usuario canceló el inicio de sesión
      }

      final GoogleSignInAuthentication googleAuth =
          await accountGoogle.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Guardar o actualizar los datos del usuario en Firestore
        await _saveUserToFirestore(user);

        // // Verificar si el campo "edad" existe
        // bool ageExists = await checkIfAgeExists(user.uid);
        return user;
      }
    } catch (e) {
      print("Error al iniciar sesión con Google: $e");
    }
    return null;
  }

  // Guardar o actualizar los datos del usuario en Firestore
  Future<void> _saveUserToFirestore(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': DateTime.now(),
        'lastLoginAt': DateTime.now(),
      });
    } else {
      await userDoc.update({
        'lastLoginAt': DateTime.now(),
      });
    }
  }

  // Verificar si el campo "edad" existe en el documento de usuario
  Future<bool> checkIfAgeExists(String userId) async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(userId).get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      return data.containsKey('edad') && data['edad'] != null;
    }

    return false;
  }
}
