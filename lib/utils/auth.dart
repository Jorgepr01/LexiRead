import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future creatAcount(String email, String pass, String name) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      print(userCredential.user?.uid);

      User? user = userCredential.user;

      // Guardar datos del usuario en Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'createdAt': DateTime.now(),
      });
      final a = userCredential.user;
      if (a?.uid != null) {
        return a?.uid;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        print("contraseña debil xd");
        return 1;
      } else if (e.code == "email-already-in-use") {
        print("ya pusiste mas");
        return 2;
      }
    } catch (e) {
      print("e");
    }
  }

  Future singInEmailAndPassword(String email, String pass) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      final a = userCredential.user;
      if (a?.uid != null) {
        return a?.uid;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return 1;
      } else if (e.code == "weong-password") {
        return 2;
      }
    }
  }

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
