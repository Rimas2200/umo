import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CoupleType extends StatefulWidget {
  @override
  _CoupleTypeState createState() => _CoupleTypeState();
}

class _CoupleTypeState extends State<CoupleType> {
  final TextEditingController _pairTypeController = TextEditingController();
  List<Map<String, dynamic>> coupleTypes = [];
  List<Map<String, dynamic>> filteredCoupleTypes = [];

  Future<void> _addCoupleType() async {
    final String pairType = _pairTypeController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/couple_types/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'pair_type': pairType,
      }),
    );

    if (response.statusCode == 201) {
      fetchCoupleTypes();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add couple type');
    }
  }

  Future<void> fetchCoupleTypes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/couple_types'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> coupleTypesArray = [];
      data.forEach((coupleType) {
        coupleTypesArray.add({
          'id': coupleType['id'] as int,
          'pair_type': coupleType['pair_type'] as String,
        });
      });
      setState(() {
        coupleTypes = coupleTypesArray;
        filteredCoupleTypes = coupleTypesArray;
      });
    } else {
      throw Exception('Failed to load couple types');
    }
  }

  void filterCoupleTypes(String query) {
    setState(() {
      filteredCoupleTypes = coupleTypes.where((coupleType) =>
          coupleType['pair_type'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  void updateCoupleType(int id, String pairType) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/couple_types/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'pair_type': pairType,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredCoupleTypes.indexWhere((coupleType) => coupleType['id'] == id);
      if (index != -1) {
        setState(() {
          filteredCoupleTypes[index]['pair_type'] = pairType;
        });
      }
    } else {
      throw Exception('Failed to update couple type');
    }
  }

  Future<void> deleteCoupleType(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/couple_types/$id'));
    if (response.statusCode == 200) {
      setState(() {
        coupleTypes.removeWhere((coupleType) => coupleType['id'] == id);
        filteredCoupleTypes.removeWhere((coupleType) => coupleType['id'] == id);
      });
    } else {
      throw Exception('Failed to delete couple type');
    }
  }

  @override
  void initState() {
    fetchCoupleTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                      filterCoupleTypes(value);
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
                          title: const Text('Добавить тип пары'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _pairTypeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Тип пары',
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
                                _addCoupleType();
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
                        'Добавить тип пары',
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
              itemCount: filteredCoupleTypes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredCoupleTypes[index]['pair_type']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String pairType = filteredCoupleTypes[index]['pair_type'];
                              TextEditingController pairTypeController = TextEditingController(text: pairType);

                              return AlertDialog(
                                title: const Text('Редактировать тип пары'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: pairTypeController,
                                        decoration: const InputDecoration(
                                          labelText: 'Тип пары',
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
                                      updateCoupleType(filteredCoupleTypes[index]['id'], pairTypeController.text); // Вызов функции для редактирования типа пары
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
                                title: const Text('Удалить тип пары?'),
                                content: const Text('Вы уверены, что хотите удалить этот тип пары?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteCoupleType(filteredCoupleTypes[index]['id']);
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
