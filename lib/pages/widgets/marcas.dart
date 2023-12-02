import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Marcas extends StatefulWidget {
  const Marcas({Key? key}) : super(key: key);

  @override
  State<Marcas> createState() => _MarcasState();
}

class _MarcasState extends State<Marcas> {
  late Future<List<String>> marcas;

  @override
  void initState() {
    super.initState();
    marcas = fetchMarcas();
  }

  Future<List<String>> fetchMarcas() async {
    final response = await http.get(Uri.parse('https://parallelum.com.br/fipe/api/v2/cars/brands'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> marcasList = data.map((item) => item['name'].toString()).toList();
      marcasList.shuffle();
      return marcasList.take(8).toList();
    } else {
      throw Exception('Falha ao carregar as marcas');
    }
  }

  Widget marcaItem(String titulo) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/acura_logo.png",
              width: 48,
            ),
            Flexible( // Ou Expanded
              child: Text(
                titulo,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(212, 212, 212, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Marcas",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "ver todas",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(53, 85, 255, 1),
                    decorationColor: Color.fromRGBO(53, 85, 255, 1),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            FutureBuilder<List<String>>(
              future: marcas,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                    gridDelegate: const  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                    ),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return marcaItem(snapshot.data![index]);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("Erro: ${snapshot.error}");
                }

                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}