import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class Positions extends StatefulWidget {
  @override
  _PositionsState createState() => _PositionsState();
}

class _PositionsState extends State<Positions> {
  final TextEditingController _positionNameController = TextEditingController();
  List<Map<String, dynamic>> positions = [];
  List<Map<String, dynamic>> filteredPositions = [];
  late String baseUrl;
  late int port;

  Future<void> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = json.decode(configString);
    setState(() {
      baseUrl = config['baseUrl'];
      port = config['port'];
    });
    fetchPositions();
  }

  Future<void> _addPosition() async {
    final String name = _positionNameController.text;

    final response = await http.post(
      Uri.parse('$baseUrl:$port/positions/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      fetchPositions();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add position');
    }
  }

  Future<void> fetchPositions() async {
    final response = await http.get(Uri.parse('$baseUrl:$port/positions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> positionsArray = [];
      data.forEach((position) {
        positionsArray.add({
          'id': position['id'] as int,
          'name': position['name'] as String,
        });
      });
      setState(() {
        positions = positionsArray;
        filteredPositions = positionsArray;
      });
    } else {
      throw Exception('Failed to load positions');
    }
  }

  void filterPositions(String query) {
    setState(() {
      filteredPositions = positions.where((position) =>
          position['name'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  void updatePosition(int id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl:$port/positions/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredPositions.indexWhere((position) => position['id'] == id);
      if (index != -1) {
        setState(() {
          filteredPositions[index]['name'] = name;
        });
      }
    } else {
      throw Exception('Failed to update position');
    }
  }

  Future<void> deletePosition(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl:$port/positions/$id'));
    if (response.statusCode == 200) {
      setState(() {
        positions.removeWhere((position) => position['id'] == id);
        filteredPositions.removeWhere((position) => position['id'] == id);
      });
    } else {
      throw Exception('Failed to delete position');
    }
  }

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Должности'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Поиск',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      filterPositions(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Добавить должность'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _positionNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Должность',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('Отмена'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _addPosition();
                              },
                              child: const Text('Добавить'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const SizedBox(
                    width: 150,
                    height: 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Добавить должность',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPositions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredPositions[index]['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String name = filteredPositions[index]['name'];
                              TextEditingController nameController = TextEditingController(text: name);

                              return AlertDialog(
                                title: const Text('Редактировать должность'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Должность',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      updatePosition(filteredPositions[index]['id'], nameController.text); // Вызов функции для редактирования должности
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Сохранить'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Удалить должность?'),
                                content: const Text('Вы уверены, что хотите удалить эту должность?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deletePosition(filteredPositions[index]['id']);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Удалить'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
