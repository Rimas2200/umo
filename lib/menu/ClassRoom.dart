import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClassRoom extends StatefulWidget {
  @override
  _ClassRoomState createState() => _ClassRoomState();
}

class _ClassRoomState extends State<ClassRoom> {
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  List<Map<String, dynamic>> classrooms = [];
  List<Map<String, dynamic>> filteredClassrooms = [];

  Future<void> _addClassroom() async {
    final String roomNumber = _roomNumberController.text;
    final String building = _buildingController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/classrooms/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'room_number': roomNumber,
        'building': building,
      }),
    );

    if (response.statusCode == 201) {
      fetchClassrooms();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add classroom');
    }
  }

  Future<void> fetchClassrooms() async {
    final response = await http.get(Uri.parse('http://localhost:3000/classrooms'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> classroomsArray = [];
      data.forEach((classroom) {
        classroomsArray.add({
          'id': classroom['id'] as int,
          'room_number': classroom['room_number'] as String,
          'building': classroom['building'] as String,
        });
      });
      setState(() {
        classrooms = classroomsArray;
        filteredClassrooms = classroomsArray;
      });
    } else {
      throw Exception('Failed to load classrooms');
    }
  }

  void filterClassrooms(String query) {
    setState(() {
      filteredClassrooms = classrooms.where((classroom) =>
      classroom['room_number'].toLowerCase().contains(query.toLowerCase()) ||
          classroom['building'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  void updateClassroom(int id, String roomNumber, String building) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/classrooms/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'room_number': roomNumber,
        'building': building,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredClassrooms.indexWhere((classroom) => classroom['id'] == id);
      if (index != -1) {
        setState(() {
          filteredClassrooms[index]['room_number'] = roomNumber;
          filteredClassrooms[index]['building'] = building;
        });
      }
    } else {
      throw Exception('Failed to update classroom');
    }
  }

  Future<void> deleteClassroom(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/classrooms/$id'));
    if (response.statusCode == 200) {
      setState(() {
        classrooms.removeWhere((classroom) => classroom['id'] == id);
        filteredClassrooms.removeWhere((classroom) => classroom['id'] == id);
      });
    } else {
      throw Exception('Failed to delete classroom');
    }
  }

  @override
  void initState() {
    fetchClassrooms();
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
                      filterClassrooms(value);
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
                          title: const Text('Добавить аудиторию'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _roomNumberController,
                                  decoration: const InputDecoration(
                                    labelText: 'Номер аудитории',
                                  ),
                                ),
                                TextField(
                                  controller: _buildingController,
                                  decoration: const InputDecoration(
                                    labelText: 'Корпус',
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
                                _addClassroom();
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
                        'Добавить аудиторию',
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
              itemCount: filteredClassrooms.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredClassrooms[index]['room_number']),
                  subtitle: Text(filteredClassrooms[index]['building']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String roomNumber = filteredClassrooms[index]['room_number'];
                              String building = filteredClassrooms[index]['building'];
                              TextEditingController roomNumberController = TextEditingController(text: roomNumber);
                              TextEditingController buildingController = TextEditingController(text: building);

                              return AlertDialog(
                                title: const Text('Редактировать аудиторию'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: roomNumberController,
                                        decoration: const InputDecoration(
                                          labelText: 'Номер аудитории',
                                        ),
                                      ),
                                      TextField(
                                        controller: buildingController,
                                        decoration: const InputDecoration(
                                          labelText: 'Корпус',
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
                                      updateClassroom(filteredClassrooms[index]['id'], roomNumberController.text, buildingController.text);
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
                                title: const Text('Удалить аудиторию?'),
                                content: const Text('Вы уверены, что хотите удалить эту аудиторию?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteClassroom(filteredClassrooms[index]['id']);
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
