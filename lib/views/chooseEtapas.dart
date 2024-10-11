import 'package:flutter/material.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:readlexi/data/datas.dart';
import 'package:readlexi/views/constants.dart';
import 'package:readlexi/screens/chooseNivel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EtapaPage extends StatefulWidget {
  const EtapaPage({super.key});

  @override
  State<EtapaPage> createState() => _EtapaPageState();
}

class _EtapaPageState extends State<EtapaPage> {
  // Método para cargar los datos desde Firestore
  Future<List<PlanetInfo>> _fetchPlanetInfo() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('etapas').get();
    return snapshot.docs.map((doc) => PlanetInfo.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 100),
          SizedBox(
            height: 500,
            child: FutureBuilder<List<PlanetInfo>>(
              future: _fetchPlanetInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar datos'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay datos disponibles'));
                } else {
                  List<PlanetInfo> etapas = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Swiper(
                      itemCount: etapas.length,
                      fade: 0.3,
                      itemWidth: MediaQuery.of(context).size.width - 2 * 64,
                      layout: SwiperLayout.STACK,
                      pagination: const SwiperPagination(
                          builder: DotSwiperPaginationBuilder(
                              color: Color.fromARGB(255, 60, 33, 31),
                              activeSize: 20,
                              activeColor: Color.fromARGB(255, 137, 21, 21),
                              space: 5)),
                      itemBuilder: (context, index) {
                        PlanetInfo planet = etapas[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (context, a, b) =>
                                      NivelsChooseView(
                                    planetInfo: planet,
                                  ),
                                  transitionsBuilder: (BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation,
                                      Widget child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ));
                          },
                          child: Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  const SizedBox(height: 100),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                    elevation: 8,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const SizedBox(height: 100),
                                          Text(
                                            planet.name ?? 'Sin nombre',
                                            style: const TextStyle(
                                                fontSize: 40,
                                                fontFamily: 'Avenir',
                                                color: Color(0xff47455f),
                                                fontWeight: FontWeight.w900),
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                            "Etapa",
                                            style: TextStyle(
                                                fontSize: 23,
                                                fontFamily: 'Avenir',
                                                color: primaryTextColor,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 32.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Realizar a etapas",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Avenir',
                                                      color: secondaryTextColor,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  textAlign: TextAlign.left,
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: secondaryTextColor,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Hero(
                                tag: planet.position,
                                child: Image.asset(planet.iconImage ??
                                    'assets/images/placeholder.png'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
