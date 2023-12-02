import 'package:flutter/material.dart';
import 'package:infocar/models/carro.dart';
import 'package:infocar/models/favoritos_carros.dart';
import 'package:provider/provider.dart';

class PagePerfil extends StatefulWidget {
  const PagePerfil({super.key});

  @override
  State<PagePerfil> createState() => _PagePerfilState();
}

class _PagePerfilState extends State<PagePerfil> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Carro carro = Carro(
          modelo: "Onix",
          marca: "Chevrolet",
          valor: 90000,
          descricao: "Onix Hatch 2023",
          imgUrl: "12345",
        );
        Provider.of<FavoritosCarros>(context, listen: false).add(carro);
      },
      child: Text(
        "Inserir carro",
        style: TextStyle(fontSize: 48),
      ),
    );
  }
}
