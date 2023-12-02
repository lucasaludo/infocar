import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MaisAcessados extends StatefulWidget {
  const MaisAcessados({Key? key}) : super(key: key);

  @override
  State<MaisAcessados> createState() => _MaisAcessadosState();
}

class _MaisAcessadosState extends State<MaisAcessados> {
  late Future<List<Map<String, dynamic>>> carros;

  @override
  void initState() {
    super.initState();
    carros = fetchCarros();
  }

  Future<List<Map<String, dynamic>>> fetchCarros() async {
    try {
      final responseMarcas = await http.get(Uri.parse('https://parallelum.com.br/fipe/api/v2/cars/brands'));

      if (responseMarcas.statusCode == 200) {
        final List<dynamic> marcasData = json.decode(responseMarcas.body);
        final String marcaId = marcasData[Random().nextInt(marcasData.length)]['code'];

        final responseCarros = await http.get(
          Uri.parse('https://parallelum.com.br/fipe/api/v2/cars/brands/$marcaId/models'),
        );

        if (responseCarros.statusCode == 200) {
          final List<dynamic> carrosData = json.decode(responseCarros.body);
          final List<Map<String, dynamic>> carros = carrosData.cast<Map<String, dynamic>>();

          // Adicione 'brandId' e 'modelId' aos carros
          carros.forEach((carro) {
            carro['brandId'] = marcaId;
            carro['modelId'] = carro['code'];
          });

          // Limitar a 8 itens
          final carrosLimitados = carros.take(8).toList();

          return carrosLimitados;
        } else {
          throw Exception('Falha ao carregar os carros da marca $marcaId');
        }
      } else {
        throw Exception('Falha ao carregar as marcas');
      }
    } catch (e) {
      print('Erro ao buscar carros mais acessados: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAnosDisponiveis(String marcaId, String modeloId) async {
    try {
      final response = await http.get(
        Uri.parse('https://parallelum.com.br/fipe/api/v2/cars/brands/$marcaId/models/$modeloId/years'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> anosData = json.decode(response.body);
        final List<Map<String, dynamic>> anos = anosData.cast<Map<String, dynamic>>();

        return anos;
      } else {
        throw Exception('Falha ao carregar anos disponíveis');
      }
    } catch (e) {
      print('Erro ao buscar anos disponíveis: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchCarroDetails(String marcaId, String modeloId, String anoId) async {
    try {
      final response = await http.get(
        Uri.parse('https://parallelum.com.br/fipe/api/v2/cars/brands/$marcaId/models/$modeloId/years/$anoId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao carregar detalhes do carro');
      }
    } catch (e) {
      print('Erro ao buscar detalhes do carro: $e');
      rethrow;
    }
  }

  Widget carroItem(Map<String, dynamic> carro) => FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchAnosDisponiveis(carro['brandId'], carro['modelId']),
      builder: (context, snapshotAnos) {
        if (snapshotAnos.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshotAnos.hasError) {
          return Text("Erro: ${snapshotAnos.error}");
        } else if (snapshotAnos.hasData) {
          final anosDisponiveis = snapshotAnos.data!;
          final anoSelecionado = anosDisponiveis.isNotEmpty ? anosDisponiveis.first['code'] : '';

          return FutureBuilder<Map<String, dynamic>>(
            future: fetchCarroDetails(carro['brandId'], carro['modelId'], anoSelecionado),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Erro: ${snapshot.error}");
              } else if (snapshot.hasData) {
                final detalhes = snapshot.data!;
                return Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/acura_logo.png", // Substitua pelo caminho correto ou dinâmico da imagem do carro
                            width: 48,
                          ),
                          Text(detalhes['model']),
                          Text(detalhes['brand']),
                          Text(detalhes['price']),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: Icon(Icons.favorite),
                        color: Colors.red,
                        onPressed: () {
                          // Lógica para lidar com o clique no botão de coração
                          // Adicione aqui o código para adicionar/remover dos favoritos
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return Text("Nenhum dado disponível");
              }
            },
          );
        } else {
          return Text("Nenhum dado disponível");
        }
      },
    );


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(212, 212, 212, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mais acessados",
            style: TextStyle(
              fontSize: 28,
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: carros,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Erro: ${snapshot.error}");
              } else if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) =>
                        carroItem(snapshot.data![index]),
                  ),
                );
              } else {
                return Text("Nenhum dado disponível");
              }
            },
          ),
        ],
      ),
    );
  }
}
