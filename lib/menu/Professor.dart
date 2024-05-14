import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Professor extends StatefulWidget {
  @override
  _ProfessorState createState() => _ProfessorState();
}

class _ProfessorState extends State<Professor> {
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  List<Map<String, dynamic>> professors = [];
  List<Map<String, dynamic>> filteredProfessors = [];

  Future<void> _addProfessor() async {
    final String lastName = _lastNameController.text;
    final String firstName = _firstNameController.text;
    final String middleName = _middleNameController.text;
    final String position = _positionController.text;
    final String departement = _departmentController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/professors/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'last_name': lastName,
        'first_name': firstName,
        'middle_name': middleName,
        'position': position,
        'departement': departement,
      }),
    );

    if (response.statusCode == 201) {
      fetchProfessors();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add professor');
    }
  }

  Future<void> fetchProfessors() async {
    final response = await http.get(Uri.parse('http://localhost:3000/professors'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> professorsArray = [];
      data.forEach((professor) {
        professorsArray.add({
          'id': professor['id'] as int,
          'last_name': professor['last_name'] as String,
          'first_name': professor['first_name'] as String,
          'middle_name': professor['middle_name'] as String,
          'position': professor['position'] as String,
          'departement': professor['departement'] as String?,
        });
      });
      setState(() {
        professors = professorsArray;
        filteredProfessors = professorsArray;
      });
    } else {
      throw Exception('Failed to load professors');
    }
  }
  void filterProfessors(String query) {
    setState(() {
      filteredProfessors = professors.where((professor) =>
      professor['last_name'].toLowerCase().contains(query.toLowerCase()) ||
          professor['first_name'].toLowerCase().contains(query.toLowerCase()) ||
          professor['middle_name'].toLowerCase().contains(query.toLowerCase()) ||
          professor['position'].toLowerCase().contains(query.toLowerCase()) ||
          (professor['departement'] != null && professor['departement']!.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    });
  }
  void updateProfessor(int id, String lastName, String firstName, String middleName, String position, String departement) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/professors/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'last_name': lastName,
        'first_name': firstName,
        'middle_name': middleName,
        'position': position,
        'departement': departement,
      }),
    );
    if (response.statusCode == 200) {
      int index = filteredProfessors.indexWhere((professor) => professor['id'] == id);
      if (index != -1) {
        setState(() {
          filteredProfessors[index]['last_name'] = lastName;
          filteredProfessors[index]['first_name'] = firstName;
          filteredProfessors[index]['middle_name'] = middleName;
          filteredProfessors[index]['position'] = position;
          filteredProfessors[index]['departement'] = departement;
        });
      }
    } else {
      throw Exception('Failed to update professor');
    }
  }

  Future<void> deleteProfessor(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/professors/$id'));
    if (response.statusCode == 200) {
      setState(() {
        professors.removeWhere((professor) => professor['id'] == id);
        filteredProfessors.removeWhere((professor) => professor['id'] == id);
      });
    } else {
      throw Exception('Failed to delete professor');
    }
  }

  @override
  void initState() {
    fetchProfessors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Преподаватели'),
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
                      filterProfessors(value);
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
                          title: const Text('Добавить преподавателя'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Фамилия',
                                  ),
                                ),
                                TextField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Имя',
                                  ),
                                ),
                                TextField(
                                  controller: _middleNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Отчество',
                                  ),
                                ),
                                TextField(
                                  controller: _positionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Должность',
                                  ),
                                ),
                                TextField(
                                  controller: _departmentController,
                                  decoration: const InputDecoration(
                                    labelText: 'Кафедра',
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
                                _addProfessor();
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
                        'Добавить преподавателя',
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
              itemCount: filteredProfessors.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${filteredProfessors[index]['last_name']} ${filteredProfessors[index]['first_name']} ${filteredProfessors[index]['middle_name']}'.trim()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(filteredProfessors[index]['position']),
                      Text(filteredProfessors[index]['departement'] ?? ''),
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
                              String lastName = filteredProfessors[index]['last_name'];
                              String firstName = filteredProfessors[index]['first_name'];
                              String middleName = filteredProfessors[index]['middle_name'];
                              String position = filteredProfessors[index]['position'];
                              String departement = filteredProfessors[index]['departement'] ?? '';
                              TextEditingController lastNameController = TextEditingController(text: lastName);
                              TextEditingController firstNameController = TextEditingController(text: firstName);
                              TextEditingController middleNameController = TextEditingController(text: middleName);
                              TextEditingController positionController = TextEditingController(text: position);
                              TextEditingController departmentController = TextEditingController(text: departement);

                              return AlertDialog(
                                title: const Text('Редактировать преподавателя'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: lastNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Фамилия',
                                        ),
                                      ),
                                      TextField(
                                        controller: firstNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Имя',
                                        ),
                                      ),
                                      TextField(
                                        controller: middleNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Отчество',
                                        ),
                                      ),
                                      TextField(
                                        controller: positionController,
                                        decoration: const InputDecoration(
                                          labelText: 'Должность',
                                        ),
                                      ),
                                      TextField(
                                        controller: departmentController,
                                        decoration: const InputDecoration(
                                          labelText: 'Кафедра',
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
                                      updateProfessor(
                                        filteredProfessors[index]['id'],
                                        lastNameController.text,
                                        firstNameController.text,
                                        middleNameController.text,
                                        positionController.text,
                                        departmentController.text,
                                      );
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
                                title: const Text('Удалить преподавателя?'),
                                content: const Text('Вы уверены, что хотите удалить этого преподавателя?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteProfessor(filteredProfessors[index]['id']);
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
