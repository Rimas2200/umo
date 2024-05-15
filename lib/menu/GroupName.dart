import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupName extends StatefulWidget {
  @override
  _GroupNameState createState() => _GroupNameState();
}

class _GroupNameState extends State<GroupName> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _directionAbbreviationController = TextEditingController();
  List<Map<String, dynamic>> groupNames = [];
  List<Map<String, dynamic>> filteredGroupNames = [];

  Future<void> _addGroupName() async {
    final String groupName = _groupNameController.text;
    final String directionAbbreviation = _directionAbbreviationController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/group_names/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': groupName,
        'direction_abbreviation': directionAbbreviation,
      }),
    );

    if (response.statusCode == 201) {
      fetchGroupNames();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add group');
    }
  }

  Future<void> fetchGroupNames() async {
    final response = await http.get(Uri.parse('http://localhost:3000/group_names'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> groupNamesArray = [];
      data.forEach((groupName) {
        groupNamesArray.add({
          'id': groupName['id'] as int,
          'name': groupName['name'] as String,
          'direction_abbreviation': groupName['direction_abbreviation'] as String,
        });
      });
      setState(() {
        groupNames = groupNamesArray;
        filteredGroupNames = groupNamesArray;
      });
    } else {
      throw Exception('Failed to load group names');
    }
  }

  void filterGroupNames(String query) {
    setState(() {
      filteredGroupNames = groupNames.where((groupName) =>
      groupName['name'].toLowerCase().contains(query.toLowerCase()) ||
          groupName['direction_abbreviation'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }
  void updateGroupName(int id, String groupName, String directionAbbreviation) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/group_names/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': groupName,
        'direction_abbreviation': directionAbbreviation,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredGroupNames.indexWhere((groupName) => groupName['id'] == id);
      if (index != -1) {
        setState(() {
          filteredGroupNames[index]['name'] = groupName;
          filteredGroupNames[index]['direction_abbreviation'] = directionAbbreviation;
        });
      }
    } else {
      throw Exception('Failed to update group');
    }
  }

  Future<void> deleteGroupName(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/group_names/$id'));
    if (response.statusCode == 200) {
      setState(() {
        groupNames.removeWhere((groupName) => groupName['id'] == id);
        filteredGroupNames.removeWhere((groupName) => groupName['id'] == id);
      });
    } else {
      throw Exception('Failed to delete group');
    }
  }
  @override
  void initState() {
    fetchGroupNames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы'),
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
                      filterGroupNames(value);
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
                          title: const Text('Добавить группу'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _groupNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Название группы',
                                  ),
                                ),
                                TextField(
                                  controller: _directionAbbreviationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Аббревиатура направления',
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
                                _addGroupName();
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
                        'Добавить группу',
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
              itemCount: filteredGroupNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredGroupNames[index]['name']),
                  subtitle: Text(filteredGroupNames[index]['direction_abbreviation']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String groupName = filteredGroupNames[index]['name'];
                              String directionAbbreviation = filteredGroupNames[index]['direction_abbreviation'];
                              TextEditingController groupNameController = TextEditingController(text: groupName);
                              TextEditingController directionAbbreviationController = TextEditingController(text: directionAbbreviation);

                              return AlertDialog(
                                title: const Text('Редактировать группу'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: groupNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Название группы',
                                        ),
                                      ),
                                      TextField(
                                        controller: directionAbbreviationController,
                                        decoration: const InputDecoration(
                                          labelText: 'Аббревиатура направления',
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
                                      updateGroupName(filteredGroupNames[index]['id'], groupNameController.text, directionAbbreviationController.text); // Вызов функции для редактирования группы
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
                                title: const Text('Удалить группу?'),
                                content: const Text('Вы уверены, что хотите удалить эту группу?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteGroupName(filteredGroupNames[index]['id']);
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
