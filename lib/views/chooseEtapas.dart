import 'package:flutter/material.dart';

import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:readlexi/data/datas.dart';
import 'package:readlexi/views/constants.dart';
import 'package:readlexi/screens/chooseNivel.dart';

class EtapaPage extends StatefulWidget {
  const EtapaPage({super.key});

  @override
  State<EtapaPage> createState() => _EtapaPageState();
}

class _EtapaPageState extends State<EtapaPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          SizedBox(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Swiper(
                itemCount: etapas.length,
                fade: 0.3,
                itemWidth: MediaQuery.of(context).size.width - 2 * 64,
                layout: SwiperLayout.STACK,
                // La parte de el ,menu de la navegacion
                pagination: const SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                        color: Color.fromARGB(255, 60, 33, 31),
                        activeSize: 20,
                        activeColor: Color.fromARGB(255, 137, 21, 21),
                        space: 5)),
                itemBuilder: (context, index) {
                  // Cambiar de paguinas
                  return InkWell(
                    // Redireccion a la paguina de los detalles
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (context, a, b) => NivelsChooseView(
                              planetInfo: etapas[index],
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
                      // el cuadrado :)
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 100,
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32)),
                              elevation: 8,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    Text(
                                      etapas[index].name.toString(),
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
                                      padding: const EdgeInsets.only(top: 32.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Realizar a etapas",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Avenir',
                                                color: secondaryTextColor,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: secondaryTextColor,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Hero(
                            tag: etapas[index].position,
                            child:
                                Image.asset(etapas[index].iconImage.toString()))
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      )),
    );
  }
}
