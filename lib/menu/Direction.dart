import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class Direction extends StatefulWidget {
  @override
  _DirectionState createState() => _DirectionState();
}

class _DirectionState extends State<Direction> {
  final TextEditingController _directionAbbreviationController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  List<Map<String, dynamic>> directions = [];
  List<Map<String, dynamic>> filteredDirections = [];
  late String baseUrl;
  late int port;

  Future<void> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = json.decode(configString);
    setState(() {
      baseUrl = config['baseUrl'];
      port = config['port'];
    });
    fetchDirections();
  }

  Future<void> _addDirection() async {
    final String directionAbbreviation = _directionAbbreviationController.text;
    final String code = _codeController.text;
    final String name = _nameController.text;
    final String faculty = _facultyController.text;

    final response = await http.post(
      Uri.parse('$baseUrl:$port/directions/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'direction_abbreviation': directionAbbreviation,
        'code': code,
        'name': name,
        'faculty': faculty,
      }),
    );

    if (response.statusCode == 201) {
      fetchDirections();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add direction');
    }
  }

  Future<void> fetchDirections() async {
    final response = await http.get(Uri.parse('$baseUrl:$port/directions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> directionsArray = [];
      data.forEach((direction) {
        directionsArray.add({
          'id': direction['id'] as int,
          'direction_abbreviation': direction['direction_abbreviation'] as String,
          'code': direction['code'] as String,
          'name': direction['name'] as String,
          'faculty': direction['faculty'] as String,
        });
      });
      setState(() {
        directions = directionsArray;
        filteredDirections = directionsArray;
      });
    } else {
      throw Exception('Failed to load directions');
    }
  }

  void filterDirections(String query) {
    setState(() {
      filteredDirections = directions.where((direction) =>
      direction['direction_abbreviation'].toLowerCase().contains(query.toLowerCase()) ||
          direction['code'].toLowerCase().contains(query.toLowerCase()) ||
          direction['name'].toLowerCase().contains(query.toLowerCase()) ||
          direction['faculty'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  void updateDirection(int id, String directionAbbreviation, String code, String name, String faculty) async {
    final response = await http.put(
      Uri.parse('$baseUrl:$port/directions/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'direction_abbreviation': directionAbbreviation,
        'code': code,
        'name': name,
        'faculty': faculty,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredDirections.indexWhere((direction) => direction['id'] == id);
      if (index != -1) {
        setState(() {
          filteredDirections[index]['direction_abbreviation'] = directionAbbreviation;
          filteredDirections[index]['code'] = code;
          filteredDirections[index]['name'] = name;
          filteredDirections[index]['faculty'] = faculty;
        });
      }
    } else {
      throw Exception('Failed to update direction');
    }
  }

  Future<void> deleteDirection(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl:$port/directions/$id'));
    if (response.statusCode == 200) {
      setState(() {
        directions.removeWhere((direction) => direction['id'] == id);
        filteredDirections.removeWhere((direction) => direction['id'] == id);
      });
    } else {
      throw Exception('Failed to delete direction');
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
        title: const Text('Направления'),
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
                      filterDirections(value);
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
                          title: const Text('Добавить направление'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _directionAbbreviationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Аббревиатура направления',
                                  ),
                                ),
                                TextField(
                                  controller: _codeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Код',
                                  ),
                                ),
                                TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Название направления',
                                  ),
                                ),
                                TextField(
                                  controller: _facultyController,
                                  decoration: const InputDecoration(
                                    labelText: 'Факультет',
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
                                _addDirection();
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
                        'Добавить направление',
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
              itemCount: filteredDirections.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredDirections[index]['direction_abbreviation']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(filteredDirections[index]['code']),
                      Text(filteredDirections[index]['name']),
                      Text(filteredDirections[index]['faculty']),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String directionAbbreviation = filteredDirections[index]['direction_abbreviation'];
                              String code = filteredDirections[index]['code'];
                              String name = filteredDirections[index]['name'];
                              String faculty = filteredDirections[index]['faculty'];
                              TextEditingController directionAbbreviationController = TextEditingController(text: directionAbbreviation);
                              TextEditingController codeController = TextEditingController(text: code);
                              TextEditingController nameController = TextEditingController(text: name);
                              TextEditingController facultyController = TextEditingController(text: faculty);

                              return AlertDialog(
                                title: const Text('Редактировать направление'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: directionAbbreviationController,
                                        decoration: const InputDecoration(
                                          labelText: 'Аббревиатура направления',
                                        ),
                                      ),
                                      TextField(
                                        controller: codeController,
                                        decoration: const InputDecoration(
                                          labelText: 'Код',
                                        ),
                                      ),
                                      TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Название направления',
                                        ),
                                      ),
                                      TextField(
                                        controller: facultyController,
                                        decoration: const InputDecoration(
                                          labelText: 'Факультет',
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
                                      updateDirection(filteredDirections[index]['id'], directionAbbreviationController.text, codeController.text, nameController.text, facultyController.text);
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
                                title: const Text('Удалить направление?'),
                                content: const Text('Вы уверены, что хотите удалить это направление?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteDirection(filteredDirections[index]['id']);
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
