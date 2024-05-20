import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class Departament extends StatefulWidget {
  @override
  _DepartamentState createState() => _DepartamentState();
}

class _DepartamentState extends State<Departament> {
  final TextEditingController _departamentNameController = TextEditingController();
  final TextEditingController _departamentPhoneController = TextEditingController();
  List<Map<String, dynamic>> departaments = [];
  List<Map<String, dynamic>> filteredDepartaments = [];
  late String baseUrl;
  late int port;

  Future<void> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = json.decode(configString);
    setState(() {
      baseUrl = config['baseUrl'];
      port = config['port'];
    });
    fetchDepartaments();
  }

  Future<void> _addDepartament() async {
    final String departamentName = _departamentNameController.text;
    final String departamentPhone = _departamentPhoneController.text;

    final response = await http.post(
      Uri.parse('$baseUrl:$port/departaments/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': departamentName,
        'phone': departamentPhone,
      }),
    );

    if (response.statusCode == 201) {
      fetchDepartaments();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add departament');
    }
  }

  Future<void> fetchDepartaments() async {
    final response = await http.get(Uri.parse('$baseUrl:$port/departaments'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> departamentsArray = [];
      data.forEach((departament) {
        departamentsArray.add({
          'id': departament['id'] as int,
          'name': departament['name'] as String,
          'phone': departament['phone'] as String,
        });
      });
      setState(() {
        departaments = departamentsArray;
        filteredDepartaments = departamentsArray;
      });
    } else {
      throw Exception('Failed to load departaments');
    }
  }

  void filterDepartaments(String query) {
    setState(() {
      filteredDepartaments = departaments.where((departament) =>
      departament['name'].toLowerCase().contains(query.toLowerCase()) ||
          departament['phone'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  void updateDepartament(int id, String departamentName, String departamentPhone) async {
    final response = await http.put(
      Uri.parse('$baseUrl:$port/departaments/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': departamentName,
        'phone': departamentPhone,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredDepartaments.indexWhere((departament) => departament['id'] == id);
      if (index != -1) {
        setState(() {
          filteredDepartaments[index]['name'] = departamentName;
          filteredDepartaments[index]['phone'] = departamentPhone;
        });
      }
    } else {
      throw Exception('Failed to update departament');
    }
  }

  Future<void> deleteDepartament(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl:$port/departaments/$id'));
    if (response.statusCode == 200) {
      setState(() {
        departaments.removeWhere((departament) => departament['id'] == id);
        filteredDepartaments.removeWhere((departament) => departament['id'] == id);
      });
    } else {
      throw Exception('Failed to delete departament');
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
        title: const Text('Кафедры'),
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
                      filterDepartaments(value);
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
                          title: const Text('Добавить кафедру'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _departamentNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Название кафедры',
                                  ),
                                ),
                                TextField(
                                  controller: _departamentPhoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Телефон кафедры',
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
                                _addDepartament();
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
                        'Добавить кафедру',
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
              itemCount: filteredDepartaments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredDepartaments[index]['name']),
                  subtitle: Text(filteredDepartaments[index]['phone']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String departamentName = filteredDepartaments[index]['name'];
                              String departamentPhone = filteredDepartaments[index]['phone'];
                              TextEditingController departamentNameController = TextEditingController(text: departamentName);
                              TextEditingController departamentPhoneController = TextEditingController(text: departamentPhone);

                              return AlertDialog(
                                title: const Text('Редактировать кафедру'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: departamentNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Название кафедры',
                                        ),
                                      ),
                                      TextField(
                                        controller: departamentPhoneController,
                                        decoration: const InputDecoration(
                                          labelText: 'Телефон кафедры',
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
                                      updateDepartament(filteredDepartaments[index]['id'], departamentNameController.text, departamentPhoneController.text); // Вызов функции для редактирования департамента
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
                                title: const Text('Удалить кафедру?'),
                                content: const Text('Вы уверены, что хотите удалить этот департамент?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteDepartament(filteredDepartaments[index]['id']);
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

