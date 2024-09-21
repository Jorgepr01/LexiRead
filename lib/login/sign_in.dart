import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/views/age.dart';
import 'package:readlexi/login/sign_up.dart';
import 'package:readlexi/screens/home.dart';
import 'package:readlexi/utils/auth.dart';
import 'package:readlexi/utils/auth_google.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthServices _auth = AuthServices();
  final authUserGoogle = AuthUserGoogle();
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              Text(
                "Welcome back",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "Login to your account",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 60),
              TextFormField(
                controller: _controllerUsername,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onEditingComplete: () => _focusNodePassword.requestFocus(),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter username.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerPassword,
                focusNode: _focusNodePassword,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: _obscurePassword
                        ? const Icon(Icons.visibility_outlined)
                        : const Icon(Icons.visibility_off_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 60),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final emailAco = _controllerUsername.text;
                        final passlAco = _controllerPassword.text;
                        var result = await _auth.singInEmailAndPassword(
                            emailAco, passlAco);
                        print(result);

                        if (result == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              width: 200,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              behavior: SnackBarBehavior.floating,
                              content: const Text("error al iniciar sesion"),
                            ),
                          );
                        } else if (result == 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              width: 200,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              behavior: SnackBarBehavior.floating,
                              content: const Text("error al iniciar sesion"),
                            ),
                          );
                        } else if (result != null) {
                          bool hasAge =
                              await authUserGoogle.checkIfAgeExists(result);
                          if (hasAge) {
                            Navigator.popAndPushNamed(context, "/home");
                          } else {
                            Navigator.popAndPushNamed(context, "/age");
                          }
                          print("ahooora");
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              width: 200,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              behavior: SnackBarBehavior.floating,
                              content: const Text("error al iniciar sesion"),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Login"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      try {
                        final user = await authUserGoogle.loginGoogleA();

                        if (user != null) {
                          // Verificar si el usuario tiene el campo 'edad'
                          bool hasAge =
                              await authUserGoogle.checkIfAgeExists(user.uid);

                          if (hasAge) {
                            // Si tiene la edad, redirigir a la página principal
                            Navigator.popAndPushNamed(context, "/home");
                          } else {
                            // Si no tiene la edad, redirigir a la pantalla para completar perfil
                            Navigator.popAndPushNamed(context, "/age");
                          }
                        }
                      } on FirebaseAuthException catch (error) {
                        print("Error de Firebase: $error");
                      } catch (error) {
                        print("Otro error: $error");
                      }
                    },
                    icon: Image.asset(
                      'assets/images/logoGoogle.png',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text("Sign in with Google"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Signup();
                              },
                            ),
                          );
                        },
                        child: const Text("Signup"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}
