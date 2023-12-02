import 'package:flutter/material.dart';
import 'package:infocar/pages/widgets/carros_disponiveis.dart';
import 'package:infocar/pages/widgets/mais_acessados.dart';
import 'package:infocar/pages/widgets/marcas.dart';

class PageCar extends StatefulWidget {
  const PageCar({Key? key}) : super(key: key);

  @override
  State<PageCar> createState() => _PageCarState();
}

class _PageCarState extends State<PageCar> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(8, 35, 8, 0),
      child: Column(
        children: [
          Marcas(),
          SizedBox(
            height: 20,
          ),
          CarrosDisponiveis(),
          SizedBox(
            height: 20,
          ),
          MaisAcessados(),
        ],
      ),
    );
  }
}
