import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readlexi/utils/logUser.dart';
import 'package:readlexi/views/chooseEtapas.dart';
import 'package:readlexi/views/motivation.dart';
import 'package:readlexi/views/selecion.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selecterindex = 0;
  final screens = [
    const LexiReadHomePage(),
    const EtapaPage(),
    MotivationalMessagesPage()
  ];
  // ignore: prefer_typing_uninitialized_variables
  var userName, email, edad;
  Future<void> fetchUserData() async {
    var userData = await _userService.getUserData();
    if (userData != null) {
      setState(() {
        userName = userData['name'];
        email = userData['email'];
        edad = userData['edad'];
      });
    }
  }

  final UserService _userService = UserService();
  // recargar
  @override
  void initState() {
    super.initState();
    fetchUserData(); // Obtener los datos al iniciar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Lexi Read"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popAndPushNamed(context, "/login");
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: screens[selecterindex],
      // Center(
      //   child: Text("ahooooora ${userName}" ?? "Oye y tu que haces aqui"),
      // ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          currentIndex: selecterindex,
          onTap: (newselecction) {
            setState(() {
              selecterindex = newselecction;
            });
          },
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.home_max),
              label: "home",
              backgroundColor: colors.primary,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset),
              activeIcon: Icon(Icons.videogame_asset_off_outlined),
              label: "game",
              backgroundColor: colors.secondary,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.connect_without_contact_outlined),
              activeIcon: Icon(Icons.connect_without_contact),
              label: "Motivation",
              backgroundColor: colors.secondary,
            )
          ]),
    );
  }
}
