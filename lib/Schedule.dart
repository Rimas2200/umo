import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  String _selectedGroup = 'МП-103';
  final List<bool> _isExpanded = [false, false, false, false, false, false];

  void _toggleExpand(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  Widget _buildDayButton(String day, int index) {
    return ElevatedButton(
      onPressed: () {
        _toggleExpand(index);
      },
      child: Text(day),
    );
  }

  Widget _buildSchedule(int index) {
    return Text('Таблица расписания для ${index + 1}');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        centerTitle: true,
        actions: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Tooltip(
                    message: 'Экспорт',
                    child: Icon(Icons.save_alt),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Tooltip(
                    message: 'Импорт',
                    child: Icon(Icons.input),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Tooltip(
                    message: 'Сохранить',
                    child: Icon(Icons.save),
                  ),
                  onPressed: () {

                  },
                ),
                IconButton(
                  icon: const Tooltip(
                    message: 'Дублировать пару',
                    child: Icon(Icons.content_copy),
                  ),
                  onPressed: () {},
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.stream),
                  tooltip: 'Выбор потока',
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'МП',
                      child: Text('МП'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'МТ',
                      child: Text('МТ'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'МН',
                      child: Text('МН'),
                    ),
                  ],
                  onSelected: (String value) {
                    print('Выбран поток: $value');
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.group),
                  tooltip: 'Выбор группы',
                  initialValue: _selectedGroup,
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'МП-103',
                      child: Text('МП-103'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'МП-102',
                      child: Text('МП-102'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'МТ-101',
                      child: Text('МТ-101'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'МТ-102',
                      child: Text('МТ-102'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'МТ-103',
                      child: Text('МТ-103'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'МН-101',
                      child: Text('МН-101'),
                    ),
                  ],
                  onSelected: (String? newValue) {
                    setState(() {
                      _selectedGroup = newValue!;
                    });
                  },
                ),

                IconButton(
                  icon: const Tooltip(
                    message: 'Добавить группу',
                    child: Icon(Icons.add),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Tooltip(
                    message: 'Удалить группу',
                    child: Icon(Icons.delete),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DayAccordion(day: 'Понедельник', selectedGroup: _selectedGroup),
            DayAccordion(day: 'Вторник', selectedGroup: _selectedGroup),
            DayAccordion(day: 'Среда', selectedGroup: _selectedGroup),
            DayAccordion(day: 'Четверг', selectedGroup: _selectedGroup),
            DayAccordion(day: 'Пятница', selectedGroup: _selectedGroup),
            DayAccordion(day: 'Суббота', selectedGroup: _selectedGroup),
          ],
        ),
      ),
    );
  }
}
class ScheduleItem {
  String? discipline;
  String? teacher;
  String? classroom;
  String? pair_name;
  String? selectedGroup;
  String? pair_time;
  String? address;

  ScheduleItem({this.discipline, this.teacher, this.classroom, this.pair_name, this.selectedGroup, this.pair_time, this.address});
}

class DayAccordion extends StatefulWidget {
  final String day;
  final String selectedGroup;

  DayAccordion({required this.day, required this.selectedGroup});

  @override
  _DayAccordionState createState() => _DayAccordionState();

  void _saveData(List<List<ScheduleItem>> schedule) {
    print('Расписание: ${day}');
    for (int i = 0; i < schedule.length; i++) {
      for (int j = 0; j < schedule[i].length; j++) {
        print('Группа: ${schedule[i][j].selectedGroup}, Подгруппа ${j+1}, Номер пары: ${schedule[i][j].pair_name}');
        print('Дисциплина: ${schedule[i][j].discipline}');
        print('Преподаватель: ${schedule[i][j].teacher}');
        print('Аудитория: ${schedule[i][j].classroom}');
        print('Адрес: ${schedule[i][j].address}');
      }
    }
  }

}

class _DayAccordionState extends State<DayAccordion> {
  bool _isExpanded = false;
  List<String> _disciplines = [];
  List<List<ScheduleItem>> _schedule = [];
  List<String> _teachers = [];
  List<String> _classrooms = [];
  List<String> _address = [];
  final List<String> _pair_name = ['', '1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> _pair_time = ['', '10:00', '11:00', '12:00'];

  @override
  void initState() {
    super.initState();
    _fetchDisciplines();
    _fetchProfessors();
    _fetchClassrooms();
    _fetchAddress();
  }

  Future<void> _fetchDisciplines() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/discipline'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('disciplines')) {
          final List<dynamic> disciplines = data['disciplines'];
          _disciplines = disciplines.map((item) => item['discipline_name'] as String).toList();
          _disciplines = _disciplines.toSet().toList();
          setState(() {
            _disciplines = _disciplines;
          });
        } else {
          throw Exception('Invalid data format: Missing "disciplines" key');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> _fetchProfessors() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/professor'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('professors')) {
          final List<dynamic> professors = data['professors'];
          for (var professor in professors) {
            String fullName = '${professor['last_name']} ${professor['initials']}';
            _teachers.add(fullName);
          }
          setState(() {
            _teachers = _teachers;
          });
        } else {
          throw Exception('Invalid data format: Missing "professors" key');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> _fetchClassrooms() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/classroom'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('classrooms')) {
          final List<dynamic> classrooms = data['classrooms'];
          _classrooms = classrooms.map((item) => item['initials'] as String).toList();
          setState(() {
            _classrooms = _classrooms.toSet().toList();
          });
        } else {
          throw Exception('Invalid data format: Missing "classrooms" key');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> _fetchAddress() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/address'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('address')) {
          final List<dynamic> address = data['address'];
          _address = address.map((item) => item['address'] as String).toList();
          _address = _address.toSet().toList();
          setState(() {
            _address = _address;
          });
        } else {
          throw Exception('Invalid data format: Missing "address" key');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.day),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      widget.selectedGroup,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _schedule
                        .map(
                          (row) => Row(
                        children: row
                            .map(
                              (item) => Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: DropdownButtonFormField<String>(
                                                  value: item.pair_name,
                                                  decoration: const InputDecoration(
                                                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                                                    hintText: '№',
                                                  ),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      item.pair_name = newValue!;
                                                    });
                                                  },
                                                  items: _pair_name.map((pairName) {
                                                    return DropdownMenuItem<String>(
                                                      value: pairName,
                                                      child: Text(pairName),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                flex: 2,
                                                child: DropdownButtonFormField<String>(
                                                  value: item.pair_time,
                                                  decoration: const InputDecoration(
                                                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                                                    hintText: 'Время',
                                                  ),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      item.pair_time = newValue!;
                                                    });
                                                  },
                                                  items: _pair_time.map((pairName) {
                                                    return DropdownMenuItem<String>(
                                                      value: pairName,
                                                      child: Text(pairName),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                flex: 5,
                                                child: Autocomplete<String>(
                                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                                    if (textEditingValue.text.isEmpty) {
                                                      return const Iterable<String>.empty();
                                                    }
                                                    return _teachers.where((String teacher) {
                                                      return teacher.toLowerCase().contains(
                                                        textEditingValue.text.toLowerCase(),
                                                      );
                                                    });
                                                  },
                                                  onSelected: (String value) {
                                                    setState(() {
                                                      item.teacher = value;
                                                    });
                                                  },
                                                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                                    return TextFormField(
                                                      controller: textEditingController,
                                                      focusNode: focusNode,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                                        labelText: 'Преподаватель',
                                                        hintText: 'Выберите или введите имя преподавателя',
                                                      ),
                                                      onChanged: (String newValue) {
                                                        setState(() {
                                                          item.teacher = newValue;
                                                        });
                                                      },
                                                      validator: (String? value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Выберите или введите имя преподавателя';
                                                        }
                                                        return null;
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Autocomplete<String>(
                                            optionsBuilder: (TextEditingValue textEditingValue) {
                                              if (textEditingValue.text.isEmpty) {
                                                return const Iterable<String>.empty();
                                              }
                                              return _disciplines.where((String option) {
                                                return option.toLowerCase().contains(
                                                  textEditingValue.text.toLowerCase(),
                                                );
                                              });
                                            },
                                            onSelected: (String value) {
                                              setState(() {
                                                item.discipline = value;
                                              });
                                            },
                                            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                              return TextFormField(
                                                controller: textEditingController,
                                                focusNode: focusNode,
                                                decoration: const InputDecoration(
                                                  labelText: 'Дисциплина',
                                                  hintText: 'Выберите или введите дисциплину',
                                                ),
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    item.discipline = newValue;
                                                  });
                                                },
                                                validator: (String? value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Выберите или введите дисциплину';
                                                  }
                                                  return null;
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Autocomplete<String>(
                                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                                    if (textEditingValue.text.isEmpty) {
                                                      return const Iterable<String>.empty();
                                                    }
                                                    return _classrooms.where((String classroom) {
                                                      return classroom.toLowerCase().contains(
                                                        textEditingValue.text.toLowerCase(),
                                                      );
                                                    });
                                                  },
                                                  onSelected: (String value) {
                                                    setState(() {
                                                      item.classroom = value;
                                                    });
                                                  },
                                                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                                    return TextFormField(
                                                      controller: textEditingController,
                                                      focusNode: focusNode,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                                        labelText: 'Аудитория',
                                                        hintText: 'Выберите или введите аудиторию',
                                                      ),
                                                      onChanged: (String newValue) {
                                                        setState(() {
                                                          item.classroom = newValue;
                                                        });
                                                      },
                                                      validator: (String? value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Выберите или введите аудиторию';
                                                        }
                                                        return null;
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                flex: 1,
                                                child: Autocomplete<String>(
                                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                                    if (textEditingValue.text.isEmpty) {
                                                      return const Iterable<String>.empty();
                                                    }
                                                    return _address.where((String address) {
                                                      return address.toLowerCase().contains(
                                                        textEditingValue.text.toLowerCase(),
                                                      );
                                                    });
                                                  },
                                                  onSelected: (String value) {
                                                    setState(() {
                                                      item.address = value;
                                                    });
                                                  },
                                                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                                    return TextFormField(
                                                      controller: textEditingController,
                                                      focusNode: focusNode,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                                        labelText: 'Адрес',
                                                        hintText: 'Выберите или введите адрес',
                                                      ),
                                                      onChanged: (String newValue) {
                                                        setState(() {
                                                          item.address = newValue;
                                                        });
                                                      },
                                                      validator: (String? value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Выберите или введите адрес';
                                                        }
                                                        return null;
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: IconButton(
                                                  icon: const Tooltip(
                                                    message: 'Сохранить',
                                                    child: Icon(Icons.save),
                                                  ),
                                                  onPressed: () {
                                                    // _showWeekRangeDialog();
                                                    _saveData();
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    // _showWeekRangeDialog();
                                                    _saveData();
                                                  },
                                                  child: const Text('Диапазон недели'),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        )
                            .toList(),
                      ),
                    )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _addScheduleRow();
                        },
                        child: const Text('Добавить пару'),
                      ),
                      if (_schedule.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            _removeLastScheduleRow();
                          },
                          child: const Text('Удалить пару'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _saveData() {
    widget._saveData(_schedule);
  }

  void _clearSchedule() {
    setState(() {
      _schedule.clear();
    });
  }

  void _addScheduleRow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int numberOfBlocks = 1;
        return AlertDialog(
          title: const Text('Введите количество подгрупп'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              numberOfBlocks = int.tryParse(value) ?? 1;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _schedule.add(List.generate(
                    numberOfBlocks,
                        (index) => ScheduleItem(selectedGroup: widget.selectedGroup),
                  ));
                });
                Navigator.of(context).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }
  void _showWeekRangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите диапазон недели'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Применить'),
            ),
          ],
        );
      },
    );
  }
  void _removeLastScheduleRow() {
    setState(() {
      _schedule.removeLast();
    });
  }
}




