import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class Discipline extends StatefulWidget {
  @override
  _DisciplineState createState() => _DisciplineState();
}

class _DisciplineState extends State<Discipline> {
  final TextEditingController _disciplineNameController = TextEditingController();
  List<Map<String, dynamic>> disciplines = [];
  List<Map<String, dynamic>> filteredDisciplines = [];
  late String baseUrl;
  late int port;

  Future<void> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = json.decode(configString);
    setState(() {
      baseUrl = config['baseUrl'];
      port = config['port'];
    });
    fetchDisciplines();
  }

  Future<void> _addDiscipline() async {
    final String disciplineName = _disciplineNameController.text;

    final response = await http.post(
      Uri.parse('$baseUrl:$port/disciplines/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'discipline_name': disciplineName,
      }),
    );

    if (response.statusCode == 201) {
      fetchDisciplines();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add discipline');
    }
  }

  Future<void> fetchDisciplines() async {
    final response = await http.get(Uri.parse('$baseUrl:$port/disciplines'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> disciplinesArray = [];
      data.forEach((discipline) {
        disciplinesArray.add({
          'id': discipline['id'] as int,
          'discipline_name': discipline['discipline_name'] as String,
        });
      });
      setState(() {
        disciplines = disciplinesArray;
        filteredDisciplines = disciplinesArray;
      });
    } else {
      throw Exception('Failed to load disciplines');
    }
  }

  void filterDisciplines(String query) {
    setState(() {
      filteredDisciplines = disciplines.where((discipline) =>
      discipline['discipline_name'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> updateDiscipline(int id, String disciplineName) async {
    final response = await http.put(
      Uri.parse('$baseUrl:$port/disciplines/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'discipline_name': disciplineName,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredDisciplines.indexWhere((discipline) => discipline['id'] == id);
      if (index != -1) {
        setState(() {
          filteredDisciplines[index]['discipline_name'] = disciplineName;
        });
      }
    } else {
      throw Exception('Failed to update discipline');
    }
  }

  Future<void> deleteDiscipline(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl:$port/disciplines/$id'));
    if (response.statusCode == 200) {
      setState(() {
        disciplines.removeWhere((discipline) => discipline['id'] == id);
        filteredDisciplines.removeWhere((discipline) => discipline['id'] == id);
      });
    } else {
      throw Exception('Failed to delete discipline');
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
        title: const Text('Дисциплины'),
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
                      filterDisciplines(value);
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
                          title: const Text('Добавить дисциплину'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _disciplineNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Название дисциплины',
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
                                _addDiscipline();
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
                        'Добавить дисциплину',
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
              itemCount: filteredDisciplines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredDisciplines[index]['discipline_name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String disciplineName = filteredDisciplines[index]['discipline_name'];
                              TextEditingController disciplineNameController = TextEditingController(text: disciplineName);

                              return AlertDialog(
                                title: const Text('Редактировать дисциплину'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: disciplineNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Название дисциплины',
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
                                      updateDiscipline(filteredDisciplines[index]['id'], disciplineNameController.text);
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
                                title: const Text('Удалить дисциплину?'),
                                content: const Text('Вы уверены, что хотите удалить эту дисциплину?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteDiscipline(filteredDisciplines[index]['id']);
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