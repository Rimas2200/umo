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
  final TextEditingController _departementController = TextEditingController();
  List<Map<String, dynamic>> professors = [];
  List<Map<String, dynamic>> filteredProfessors = [];
  List<Map<String, dynamic>> positions = [];
  List<Map<String, dynamic>> filteredPositions = [];
  List<Map<String, dynamic>> departaments = [];
  List<Map<String, dynamic>> filteredDepartaments = [];
  String selectedPosition = '';
  String baseUrl = '';
  int port = 0;
  Map<String, dynamic>? selectedDepartment;

  @override
  void initState() {
    super.initState();
    loadConfig().then((_) {
      fetchDepartaments();
      fetchPositions();
    }).catchError((error) {
      print('Error loading configuration: $error');
    });
  }

  Future<void> loadConfig() async {
    try {
      String content = await DefaultAssetBundle.of(context).loadString('assets/config.json');
      Map<String, dynamic> config = jsonDecode(content);
      baseUrl = config['baseUrl'];
      port = config['port'];
      fetchProfessors();
    } catch (e) {
      print('Ошибка при загрузке конфигурационного файла: $e');
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
  Future<void> _addProfessor() async {
    final String lastName = _lastNameController.text;
    final String firstName = _firstNameController.text;
    final String middleName = _middleNameController.text;
    final String departement = _departementController.text;

    final response = await http.post(
      Uri.parse('$baseUrl:$port/professors/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'last_name': lastName,
        'first_name': firstName,
        'middle_name': middleName,
        'position': selectedPosition,
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
    final response = await http.get(Uri.parse('$baseUrl:$port/professors'));
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
          'departement': professor['departement'] as String,
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
          (professor['departement'].toLowerCase().contains(query.toLowerCase()))
      ).toList();
    });
  }

  void updateProfessor(int id, String lastName, String firstName, String middleName, String position, String departement) async {
    final response = await http.put(
      Uri.parse('$baseUrl:$port/professors/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'last_name': lastName,
        'first_name': firstName,
        'middle_name': middleName,
        'position': position,
        'departement': selectedDepartment != null ? selectedDepartment!['name'] : departement,
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
    final response = await http.delete(Uri.parse('$baseUrl:$port/professors/$id'));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Преподаватели'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchProfessors();
            },
          ),
        ],
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
                                DropdownButtonFormField<String>(
                                  value: selectedPosition.isEmpty ? null : selectedPosition,
                                  items: positions.map((Map<String, dynamic> position) {
                                    return DropdownMenuItem<String>(
                                      value: position['name'] as String,
                                      child: Text(position['name'] as String),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedPosition = newValue!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Должность',
                                  ),
                                ),

                                DropdownButtonFormField<Map<String, dynamic>>(
                                  value: null,
                                  items: filteredDepartaments.map((Map<String, dynamic> departament) {
                                    return DropdownMenuItem<Map<String, dynamic>>(
                                      value: departament,
                                      child: Text(departament['name'] as String),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    _departementController.text = newValue!['name'] as String;
                                  },
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
                  title: Text(
                      '${filteredProfessors[index]['last_name']} ${filteredProfessors[index]['first_name']} ${filteredProfessors[index]['middle_name']} - ${filteredProfessors[index]['position']}'
                  ),
                  subtitle: Text(filteredProfessors[index]['departement']),
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
                              String departement = filteredProfessors[index]['departement'];
                              TextEditingController lastNameController = TextEditingController(text: lastName);
                              TextEditingController firstNameController = TextEditingController(text: firstName);
                              TextEditingController middleNameController = TextEditingController(text: middleName);
                              TextEditingController positionController = TextEditingController(text: position);
                              TextEditingController departementController = TextEditingController(text: departement);

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
                                      DropdownButtonFormField<String>(
                                        value: null,
                                        items: positions.map((Map<String, dynamic> position) {
                                          return DropdownMenuItem<String>(
                                            value: position['name'] as String,
                                            child: Text(position['name'] as String),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            positionController.text = newValue!;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Должность',
                                        ),
                                      ),
                                      DropdownButtonFormField<Map<String, dynamic>>(
                                        value: null,
                                        items: filteredDepartaments.map((Map<String, dynamic> departament) {
                                          return DropdownMenuItem<Map<String, dynamic>>(
                                            value: departament,
                                            child: Text(departament['name'] as String),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedDepartment = newValue;
                                            _departementController.text = newValue!['name'] as String;
                                          });
                                        },
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
                                        departementController.text,
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
