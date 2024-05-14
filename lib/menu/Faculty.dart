import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Faculty extends StatefulWidget {
  @override
  _FacultyState createState() => _FacultyState();
}

class _FacultyState extends State<Faculty> {
  final TextEditingController _facultyNameController = TextEditingController();
  final TextEditingController _deanFullnameController = TextEditingController();
  List<Map<String, dynamic>> faculties = [];
  List<Map<String, dynamic>> filteredFaculties = [];

  Future<void> _addFaculty() async {
    final String facultyName = _facultyNameController.text;
    final String deanFullname = _deanFullnameController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/faculties/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'faculty_name': facultyName,
        'dean_fullname': deanFullname,
      }),
    );

    if (response.statusCode == 201) {
      fetchFaculties();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add faculty');
    }
  }

  Future<void> fetchFaculties() async {
    final response = await http.get(Uri.parse('http://localhost:3000/faculties'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> facultiesArray = [];
      data.forEach((faculty) {
        facultiesArray.add({
          'id': faculty['id'] as int,
          'faculty_name': faculty['faculty_name'] as String,
          'dean_fullname': faculty['dean_fullname'] as String,
        });
      });
      setState(() {
        faculties = facultiesArray;
        filteredFaculties = facultiesArray;
      });
    } else {
      throw Exception('Failed to load faculties');
    }
  }

  void filterFaculties(String query) {
    setState(() {
      filteredFaculties = faculties.where((faculty) =>
      faculty['faculty_name'].toLowerCase().contains(query.toLowerCase()) ||
          faculty['dean_fullname'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }
  void updateFaculty(int id, String facultyName, String deanFullname) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/faculties/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'faculty_name': facultyName,
        'dean_fullname': deanFullname,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredFaculties.indexWhere((faculty) => faculty['id'] == id);
      if (index != -1) {
        setState(() {
          filteredFaculties[index]['faculty_name'] = facultyName;
          filteredFaculties[index]['dean_fullname'] = deanFullname;
        });
      }
    } else {
      throw Exception('Failed to update faculty');
    }
  }

  Future<void> deleteFaculty(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/faculties/$id'));
    if (response.statusCode == 200) {
      setState(() {
        faculties.removeWhere((faculty) => faculty['id'] == id);
        filteredFaculties.removeWhere((faculty) => faculty['id'] == id);
      });
    } else {
      throw Exception('Failed to delete faculty');
    }
  }
  @override
  void initState() {
    fetchFaculties();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      filterFaculties(value);
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
                          title: const Text('Добавить факультет'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _facultyNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Название факультета',
                                  ),
                                ),
                                TextField(
                                  controller: _deanFullnameController,
                                  decoration: const InputDecoration(
                                    labelText: 'ФИО декана',
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
                                _addFaculty();
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
                        'Добавить факультет',
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
              itemCount: filteredFaculties.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredFaculties[index]['faculty_name']),
                  subtitle: Text(filteredFaculties[index]['dean_fullname']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String facultyName = filteredFaculties[index]['faculty_name'];
                              String deanFullname = filteredFaculties[index]['dean_fullname'];
                              TextEditingController facultyNameController = TextEditingController(text: facultyName);
                              TextEditingController deanFullnameController = TextEditingController(text: deanFullname);

                              return AlertDialog(
                                title: const Text('Редактировать факультет'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: facultyNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Название факультета',
                                        ),
                                      ),
                                      TextField(
                                        controller: deanFullnameController,
                                        decoration: const InputDecoration(
                                          labelText: 'ФИО декана',
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
                                      updateFaculty(filteredFaculties[index]['id'], facultyNameController.text, deanFullnameController.text); // Вызов функции для редактирования факультета
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
                                title: const Text('Удалить факультет?'),
                                content: const Text('Вы уверены, что хотите удалить этот факультет?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteFaculty(filteredFaculties[index]['id']);
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
