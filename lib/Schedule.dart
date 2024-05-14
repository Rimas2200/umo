import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Schedule extends StatefulWidget {
  final String? selectedFaculty;

  const Schedule({Key? key, this.selectedFaculty}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  String _selectedGroup = 'Выберете группу!';
  late List<bool> _isExpanded;
  List<String> _directions = [];
  var logger = Logger();
  List<String> _groups = [];
  @override
  void initState() {
    super.initState();
    _fetchDirections();
    _isExpanded = List<bool>.generate(6, (index) => false);
  }

  void _toggleExpand(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  Future<void> _fetchDirections() async {
    try {
      final List<String> directions = await fetchDirections(widget.selectedFaculty!);
      setState(() {
        _directions = directions;
      });
    } catch (error) {
      logger.e('Error fetching directions: $error');
    }
  }

  Future<List<String>> fetchDirections(String facultyId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/directions/$facultyId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.map((item) => item['direction_abbreviation'] as String).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load directions: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching directions: $error');
    }
  }
  Future<void> fetchGroups(String directionId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/group_name/$directionId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _groups = data.map((item) => item['name'] as String).toList();
          });
        } else {
          setState(() {
            _groups = [];
          });
        }
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching groups: $error');
    }
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
                  onPressed: () {
                  },
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
                  itemBuilder: (BuildContext context) {
                    return _directions.map((direction) {
                      return PopupMenuItem<String>(
                        value: direction,
                        child: Text(direction),
                      );
                    }).toList();
                  },
                  onSelected: (String value) async {
                    try {
                      await fetchGroups(value);
                    } catch (error) {
                      logger.e('Error fetching groups: $error');
                    }
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.group),
                  tooltip: 'Выбор группы',
                  initialValue: _selectedGroup,
                  itemBuilder: (BuildContext context) {
                    return _groups.map((group) {
                      return PopupMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList();
                  },
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
  // ignore: non_constant_identifier_names
  String? pair_name;
  String? selectedGroup;
  // ignore: non_constant_identifier_names
  String? pair_time;
  String? address;
  // ignore: non_constant_identifier_names
  String? pair_type;
  // ignore: non_constant_identifier_names
  String? day_of_the_week;

  // ignore: non_constant_identifier_names
  ScheduleItem({this.discipline, this.teacher, this.classroom, this.pair_name, this.selectedGroup, this.pair_time, this.address, this.pair_type, this.day_of_the_week});
}

class DayAccordion extends StatefulWidget {

  final String day;
  final String selectedGroup;
  var logger = Logger();

  DayAccordion({required this.day, required this.selectedGroup});

  @override
  _DayAccordionState createState() => _DayAccordionState();

  void _saveData(List<List<ScheduleItem>> schedule, context) async {
    for (int i = 0; i < schedule.length; i++) {
      for (int j = 0; j < schedule[i].length; j++) {
        if(schedule[i][j].discipline != null && schedule[i][j].pair_type != null){
          logger.i('discipline: ${schedule[i][j].discipline} ${schedule[i][j].pair_type}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не заполнено поле с дисциплиной или не выбран тип пары'),
              duration: Duration(seconds: 3),
            ),
          );
          continue;
        }

        if (schedule[i][j].classroom != null) {
          logger.i('classroom: ${schedule[i][j].classroom}');
        } else if (schedule[i][j].address != null){
          logger.i('classroom: ${schedule[i][j].address}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не заполнено поле с аудиторией или адресом'),
              duration: Duration(seconds: 3),
            ),
          );
          continue;
        }

        if(schedule[i][j].selectedGroup != null){
          logger.i('group_name: ${schedule[i][j].selectedGroup}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не выбранна группа'),
              duration: Duration(seconds: 3),
            ),
          );
          continue;
        }

        if (schedule[i][j].pair_name != null) {
          logger.i('pair_name: ${schedule[i][j].pair_name}');
        } else if (schedule[i][j].pair_time != null) {
          logger.i('pair_name: ${schedule[i][j].pair_time}');
        } else if (schedule[i][j].pair_time == null){
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не выбран номер пары или время'),
              duration: Duration(seconds: 3),
            ),
          );
          continue;
        }

        if(schedule[i][j].teacher != null) {
          logger.i('teacher_name: ${schedule[i][j].teacher}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не заполнено поле с преподавателем'),
              duration: Duration(seconds: 3),
            ),
          );
          continue;
        }
        logger.i('day_of_the_week: $day');
        if (schedule[i][j].day_of_the_week != null) {
          logger.i('week: ${schedule[i][j].day_of_the_week}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не выбран диапазон недель'),
              duration: Duration(seconds: 3),
            ),
          );
          continue;
        }
        String subgroup;
        if (j-1>=0) {
          subgroup = '${j + 1}';
          logger.i(subgroup);
        } else {
          subgroup = 'нет разделения';
          logger.i('нет разделения');
        }
        final url = Uri.parse('http://localhost:3000/timetable');
        final body = jsonEncode({
          'discipline': '${schedule[i][j].discipline} ${schedule[i][j].pair_type}',
          'classroom': schedule[i][j].classroom ?? schedule[i][j].address,
          'group_name': schedule[i][j].selectedGroup,
          'pair_name': schedule[i][j].pair_name ?? schedule[i][j].pair_time,
          'teacher_name': schedule[i][j].teacher,
          'day_of_the_week': day,
          'week': schedule[i][j].day_of_the_week,
          'subgroup': subgroup,
        });
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          logger.i('Данные успешно отправлены');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Данные успешно отправлены'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          logger.e('Ошибка при отправке данных: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка при отправке данных'),
              duration: Duration(seconds: 3),
            ),
          );
          logger.e(response.body);
        }
      }
    }
  }
}

class _DayAccordionState extends State<DayAccordion> {
  bool _isExpanded = false;
  List<String> _disciplines = [];
  ScheduleItem item = ScheduleItem();
  final List<List<ScheduleItem>> _schedule = [];
  // ignore: non_constant_identifier_names
  List<String> _pair_type = [];
  List<String> _teachers = [];
  List<String> _classrooms = [];
  List<String> _address = [];
  var logger = Logger();
  // ignore: non_constant_identifier_names
  final List<String> _pair_name = ['', '1', '2', '3', '4', '5', '6', '7', '8'];
  // ignore: non_constant_identifier_names
  final List<String> _pair_time = ['', '10:00', '11:00', '12:00'];

  @override
  void initState() {
    super.initState();
    _fetchDisciplines();
    _fetchProfessors();
    _fetchClassrooms();
    _fetchAddress();
    _fetchCoupletype();
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
      logger.e('Error: $error');
    }
  }
  Future<void> _fetchCoupletype() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/couple_type'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('pair_type')) {
          final List<dynamic> pairType = data['pair_type'];
          _pair_type = pairType.map((item) => item['pair_type'] as String).toList();
          _pair_type = _pair_type.toSet().toList();
          setState(() {
            _pair_type = _pair_type;
          });
        } else {
          throw Exception('Invalid data format: Missing "pair_type" key');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error: $error');
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
      logger.e('Error: $error');
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
      logger.e('Error: $error');
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
      logger.e('Error: $error');
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
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Autocomplete<String>(
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
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 1,
                                                child: Autocomplete<String>(
                                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                                    if (textEditingValue.text.isEmpty) {
                                                      return const Iterable<String>.empty();
                                                    }
                                                    return _pair_type.where((String teacher) {
                                                      return teacher.toLowerCase().contains(
                                                        textEditingValue.text.toLowerCase(),
                                                      );
                                                    });
                                                  },
                                                  onSelected: (String value) {
                                                    setState(() {
                                                      item.pair_type = value;
                                                    });
                                                  },
                                                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                                    return TextFormField(
                                                      controller: textEditingController,
                                                      focusNode: focusNode,
                                                      decoration: const InputDecoration(
                                                        // contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                                        labelText: 'Тип пары',
                                                        hintText: 'Выберите или введите тип пары',
                                                      ),
                                                      onChanged: (String newValue) {
                                                        setState(() {
                                                          item.pair_type = newValue;
                                                        });
                                                      },
                                                      validator: (String? value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Выберите или введите тип пары';
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
                                                    _saveData(context);
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _showWeekRangeDialog(context, (newValue) {
                                                      setState(() {
                                                        item.day_of_the_week = newValue;
                                                      });
                                                    });
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
                      if(widget.selectedGroup != "Выберете группу!")
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

  void _saveData(context) {
    widget._saveData(_schedule, context);
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
  void _showWeekRangeDialog(BuildContext context, Function(String) callback) {
    List<bool> isSelected = List.generate(18, (_) => false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Выберите диапазон недели'),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView.count(
                      crossAxisCount: 6,
                      shrinkWrap: true,
                      children: List.generate(18, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isSelected[index] = !isSelected[index];
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected[index] ? Colors.blue : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = (i + 1) % 2 != 0;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            ),
                            child: const Text('1Н'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = (i + 1) % 2 == 0;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            ),
                            child: const Text('2Н'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = true;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 20),
                            ),
                            child: const Text('Все'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = false;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            ),
                            child: const Text('Сброс'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    _applySelection(isSelected, callback);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Применить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applySelection(List<bool> isSelected, Function(String) callback) {
    String selectedNumbers = '';
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i]) {
        selectedNumbers += '${i + 1} ';
      }
    }
    callback(selectedNumbers);
  }

  void callback(String newValue) {
    setState(() {
      item.day_of_the_week = newValue;
    });
  }

  void _removeLastScheduleRow() {
    setState(() {
      _schedule.removeLast();
    });
  }
}




