import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimetablePage extends StatefulWidget {
  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<TimetablePage> {
  bool _isLoading = false;
  final Map<String, String> _selectedRooms = {};
  List<Map<String, dynamic>> classrooms = [];
  List<Map<String, dynamic>> filteredClassrooms = [];
  Map<String, List<Map<String, dynamic>>> _schedule = {};
  late String baseUrl;
  late int port;

  @override
  void initState() {
    super.initState();
    fetchClassrooms();
  }

  Future<Map<String, dynamic>> _loadConfig() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/config.json');
      return jsonDecode(jsonString);
    } catch (e) {
      print('Error loading config: $e');
      throw Exception('Failed to load configuration');
    }
  }

  Future<void> fetchClassrooms() async {
    try {
      final config = await _loadConfig();
      baseUrl = config['baseUrl'];
      port = config['port'];
      final response = await http.get(Uri.parse('$baseUrl:$port/classrooms'));
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
        if (mounted) {
          setState(() {
            classrooms = classroomsArray;
            filteredClassrooms = classroomsArray;
          });
        }
      } else {
        throw Exception('Failed to load classrooms');
      }
    } catch (e) {
      print('Error fetching classrooms: $e');
    }
  }

  Future<void> fetchSchedule(String classroom) async {
    try {
      final config = await _loadConfig();
      final url = Uri.parse('$baseUrl:$port/schedule/$classroom');
      print('Fetching schedule for classroom: $classroom from URL: $url');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> parsedData = [];
        for (var entry in data) {
          if (entry is String) {
            List<String> parts = entry.split(' ');
            String group = parts[0];
            String pairNumber = parts[1];
            String dayOfWeek = parts[2];
            List<String> weeks = parts.sublist(3);

            parsedData.add({
              'group': group,
              'pairNumber': pairNumber,
              'dayOfWeek': dayOfWeek,
              'weeks': weeks,
            });
          }
        }
        if (mounted) {
          setState(() {
            _schedule[classroom] = parsedData;
          });
        }
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      print('Error fetching schedule: $e');
    }
  }

  void _refreshData() {
    fetchClassrooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Шахматка'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Семестр:'),
                        TextField(
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Учебный год:'),
                        TextField(
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 26),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Сформировать'),
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
                  TableRow(
                    children: [
                      const TableCell(child: Center(child: Text('День недели'))),
                      const TableCell(child: Center(child: Text('Четность недели'))),
                      for (var i = 1; i <= 8; i++)
                        TableCell(
                          child: Center(
                            child: Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return classrooms
                                    .map((classroom) => classroom['room_number'] as String)
                                    .where((String option) {
                                  return option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  );
                                });
                              },
                              onSelected: (String value) {
                                setState(() {
                                  _selectedRooms['room_$i'] = value;
                                  fetchSchedule(value);
                                });
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                    labelText: 'Аудитория',
                                    hintText: 'Выберите или введите название аудитории',
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (var day in ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница'])
                    ...List.generate(8, (pairIndex) {
                      final pairNumber = (pairIndex + 1).toString();
                      return [
                        TableRow(
                          children: [
                            if (pairIndex == 0)
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Center(child: Text(day)),
                              )
                            else
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Container(),
                              ),
                            TableCell(child: Center(child: Text('$pairNumber 1Н'))),
                            for (var i = 1; i <= 8; i++)
                              TableCell(
                                child: Center(
                                  child: Text(
                                    _getScheduleForRoom(day, pairNumber, '1Н', _selectedRooms['room_$i'] ?? ''),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Container(),
                            ),
                            TableCell(child: Center(child: Text('$pairNumber 2Н'))),
                            for (var i = 1; i <= 8; i++)
                              TableCell(
                                child: Center(
                                  child: Text(
                                    _getScheduleForRoom(day, pairNumber, '2Н', _selectedRooms['room_$i'] ?? ''),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ];
                    }).expand((pairRows) => pairRows).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getScheduleForRoom(String day, String pairNumber, String weekType, String room) {
    if (_schedule.containsKey(room)) {
      List<Map<String, dynamic>> scheduleList = _schedule[room]!;
      for (var entry in scheduleList) {
        if (entry['dayOfWeek'] == day && entry['pairNumber'] == pairNumber && entry['weeks'].contains(weekType)) {
          return entry['group'];
        }
      }
    }
    return '';
  }
}
