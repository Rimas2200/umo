import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Extracts extends StatefulWidget {
  @override
  _ExtractsState createState() => _ExtractsState();
}

class _ExtractsState extends State<Extracts> {
  String? selectedDepartment;
  String? selectedTeacher;
  List<String> _departments = [];
  List<String> _professors = [];
  List<Map<String, dynamic>> _scheduleData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<Map<String, dynamic>> _loadConfig() async {
    final String jsonString =
    await DefaultAssetBundle.of(context).loadString('assets/config.json');
    return jsonDecode(jsonString);
  }

  Future<void> fetchDepartments() async {
    try {
      final config = await _loadConfig();
      final response = await http
          .get(Uri.parse('${config['baseUrl']}:${config['port']}/departament'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _departments =
              data.map((item) => item['name'] as String).toList();
        });
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      print('Error fetching departments: $e');
    }
  }

  Future<void> fetchProfessors(String department) async {
    try {
      final config = await _loadConfig();
      final response = await http.get(Uri.parse(
          '${config['baseUrl']}:${config['port']}/professor/$department'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _professors =
              data.map((item) => item['name'] as String).toList();
        });
      } else {
        throw Exception('Failed to load professors');
      }
    } catch (e) {
      print('Error fetching professors: $e');
    }
  }

  Future<void> fetchSchedule(String teacherName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final config = await _loadConfig();
      final response = await http.get(Uri.parse(
          '${config['baseUrl']}:${config['port']}/schedule/extracts/teacher?teacher_name=$teacherName'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _scheduleData = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshData() {
    if (selectedTeacher != null) {
      fetchSchedule(selectedTeacher!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выписки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Выберите кафедру:'),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _departments.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String value) {
                          setState(() {
                            selectedDepartment = value;
                            selectedTeacher = null;
                            _professors = [];
                            fetchProfessors(value);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Выберите преподавателя:'),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _professors.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String value) {
                          setState(() {
                            selectedTeacher = value;
                            if (value.isNotEmpty) {
                              fetchSchedule(value);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(100),
                1: FixedColumnWidth(150),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
                5: FlexColumnWidth(),
                6: FlexColumnWidth(),
                7: FlexColumnWidth(),
                8: FlexColumnWidth(),
                9: FlexColumnWidth(),
              },
              children: [
                const TableRow(
                  children: [
                    TableCell(child: Center(child: Text('День недели'))),
                    TableCell(child: Center(child: Text('Четность недели'))),
                    TableCell(child: Center(child: Text('1'))),
                    TableCell(child: Center(child: Text('2'))),
                    TableCell(child: Center(child: Text('3'))),
                    TableCell(child: Center(child: Text('4'))),
                    TableCell(child: Center(child: Text('5'))),
                    TableCell(child: Center(child: Text('6'))),
                    TableCell(child: Center(child: Text('7'))),
                    TableCell(child: Center(child: Text('8'))),
                  ],
                ),
                for (var day in ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница'])
                  ...[
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text(day))),
                        const TableCell(child: Center(child: Text('1Н'))),
                        for (var i = 1; i <= 8; i++)
                          TableCell(
                            child: Center(
                              child: Text(
                                _scheduleData.isNotEmpty && _scheduleData.any((item) =>
                                item['day_of_the_week'] == day &&
                                    item['pair_name'] == i.toString() &&
                                (_getWeekType(item['week']) == '1Н' || _getWeekType(item['week']) == '1Н и 2Н')
                                ) ? _scheduleData.firstWhere((item) =>
                                item['day_of_the_week'] == day &&
                                    item['pair_name'] == i.toString())['group_name'] : '',
                              ),
                            ),
                          ),

                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text(day))),
                        const TableCell(child: Center(child: Text('2Н'))),
                        for (var i = 1; i <= 8; i++)
                          TableCell(
                            child: Center(
                              child: Text(
                                _scheduleData.isNotEmpty && _scheduleData.any((item) =>
                                item['day_of_the_week'] == day &&
                                    item['pair_name'] == i.toString() &&
                                    (_getWeekType(item['week']) == '2Н' || _getWeekType(item['week']) == '1Н и 2Н')
                                ) ? _scheduleData.firstWhere((item) =>
                                item['day_of_the_week'] == day &&
                                    item['pair_name'] == i.toString())['group_name'] : '',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  String _getWeekType(String weekString) {
    bool hasEven = false;
    bool hasOdd = false;

    List<String> weeks = weekString.split(' ');
    for (var week in weeks) {
      int? weekNumber = int.tryParse(week);
      if (weekNumber != null) {
        if (weekNumber % 2 == 0) {
          hasEven = true;
        } else {
          hasOdd = true;
        }
      }
    }
    if (hasEven && hasOdd) {
      return '1Н и 2Н';
    } else if (hasEven) {
      return '2Н';
    } else if (hasOdd) {
      return '1Н';
    } else {
      return 'Нет данных';
    }
  }
}
