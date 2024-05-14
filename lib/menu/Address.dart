import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Address extends StatefulWidget {
  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  List<Map<String, dynamic>> addresses = [];
  List<Map<String, dynamic>> filteredAddresses = [];

  Future<void> _addAddress() async {
    final String address = _addressController.text;
    final String faculty = _facultyController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/addresses/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'address': address,
        'faculty': faculty,
      }),
    );

    if (response.statusCode == 201) {
      fetchAddresses();
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to add address');
    }
  }

  Future<void> fetchAddresses() async {
    final response = await http.get(Uri.parse('http://localhost:3000/addresses'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> addressesArray = [];
      data.forEach((address) {
        addressesArray.add({
          'id': address['id'] as int,
          'address': address['address'] as String,
          'faculty': address['faculty'] as String,
        });
      });
      setState(() {
        addresses = addressesArray;
        filteredAddresses = addressesArray;
      });
    } else {
      throw Exception('Failed to load addresses');
    }
  }

  void filterAddresses(String query) {
    setState(() {
      filteredAddresses = addresses.where((address) =>
      address['address'].toLowerCase().contains(query.toLowerCase()) ||
          address['faculty'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  void updateAddress(int id, String address, String faculty) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/addresses/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'address': address,
        'faculty': faculty,
      }),
    );

    if (response.statusCode == 200) {
      int index = filteredAddresses.indexWhere((address) => address['id'] == id);
      if (index != -1) {
        setState(() {
          filteredAddresses[index]['address'] = address;
          filteredAddresses[index]['faculty'] = faculty;
        });
      }
    } else {
      throw Exception('Failed to update address');
    }
  }

  Future<void> deleteAddress(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/addresses/$id'));
    if (response.statusCode == 200) {
      setState(() {
        addresses.removeWhere((address) => address['id'] == id);
        filteredAddresses.removeWhere((address) => address['id'] == id);
      });
    } else {
      throw Exception('Failed to delete address');
    }
  }

  @override
  void initState() {
    fetchAddresses();
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
                      filterAddresses(value);
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
                          title: const Text('Добавить адрес'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Адрес',
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
                                _addAddress();
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
                        'Добавить адрес',
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
              itemCount: filteredAddresses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredAddresses[index]['address']),
                  subtitle: Text(filteredAddresses[index]['faculty']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String address = filteredAddresses[index]['address'];
                              String faculty = filteredAddresses[index]['faculty'];
                              TextEditingController addressController = TextEditingController(text: address);
                              TextEditingController facultyController = TextEditingController(text: faculty);

                              return AlertDialog(
                                title: const Text('Редактировать адрес'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: addressController,
                                        decoration: const InputDecoration(
                                          labelText: 'Адрес',
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
                                      updateAddress(filteredAddresses[index]['id'], addressController.text, facultyController.text);
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
                                title: const Text('Удалить адрес?'),
                                content: const Text('Вы уверены, что хотите удалить этот адрес?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteAddress(filteredAddresses[index]['id']);
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
