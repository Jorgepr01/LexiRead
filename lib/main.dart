import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:readlexi/views/age.dart';
import 'package:readlexi/screens/home.dart';
import 'package:readlexi/login/sign_in.dart';
import 'package:readlexi/login/sign_up.dart';
import 'package:readlexi/utils/auth_google.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para usar Firestore
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/home": (context) => Home(),
        "/login": (context) => Login(),
        "/register": (context) => Signup(),
        "/age": (context) => AgeSelectionScreen()
      },
      title: 'Login & Register',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthCheck(),
    );
  }
}

// Widget que verifica si el usuario está autenticado
class AuthCheck extends StatelessWidget {
  final AuthUserGoogle authUserGoogle = AuthUserGoogle();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return Login(); // No hay usuario autenticado, muestra pantalla de login
          } else {
            // Verificar si el usuario tiene el campo 'edad'
            return FutureBuilder<bool>(
              future: authUserGoogle.checkIfAgeExists(user.uid),
              builder: (context, ageSnapshot) {
                if (ageSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (ageSnapshot.hasData && ageSnapshot.data == true) {
                  // Verificar y restaurar vidas antes de redirigir al Home
                  // Si el usuario tiene 'edad', redirige a Home
                  return Home();
                } else {
                  // Si el usuario no tiene 'edad', redirige a completar perfil
                  return AgeSelectionScreen();
                }
              },
            );
          }
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
