import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TimetableGroup extends StatefulWidget {
  final String selectedGroup;

  const TimetableGroup({Key? key, required this.selectedGroup}) : super(key: key);

  @override
  _TimetableGroupState createState() => _TimetableGroupState();
}

class _TimetableGroupState extends State<TimetableGroup> {
  late Future<List<Map<String, dynamic>>> _futureGroupSchedule;

  @override
  void initState() {
    super.initState();
    _futureGroupSchedule = fetchGroupSchedule(widget.selectedGroup);
  }

  Future<List<Map<String, dynamic>>> fetchGroupSchedule(String groupName) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/schedule/group?group_name=$groupName'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load group schedule: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching group schedule: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание группы ${widget.selectedGroup}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureGroupSchedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('Расписание для группы ${widget.selectedGroup} не найдено.'));
          } else {
            final List<Map<String, dynamic>> schedule = snapshot.data!;
            Map<String, Map<String, List<Map<String, dynamic>>>> groupedSchedule = {};
            schedule.forEach((item) {
              final dayOfWeek = item['day_of_the_week'];
              final subgroup = item['subgroup'];
              if (!groupedSchedule.containsKey(dayOfWeek)) {
                groupedSchedule[dayOfWeek] = {};
              }
              if (!groupedSchedule[dayOfWeek]!.containsKey(subgroup)) {
                groupedSchedule[dayOfWeek]![subgroup] = [];
              }
              groupedSchedule[dayOfWeek]![subgroup]!.add(item);
            });
            return ListView(
              children: groupedSchedule.keys.map((day) {
                final daySchedule = groupedSchedule[day]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        day,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: daySchedule.keys.map((subgroup) {
                        final subgroupSchedule = daySchedule[subgroup]!;
                        return ExpansionTile(
                          title: Text(
                            'Подгруппа $subgroup',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: subgroupSchedule.map((scheduleItem) {
                            return ListTile(
                              title: Text(
                                '${scheduleItem['pair_name']} ${scheduleItem['discipline']}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                              subtitle: Text(
                                '${scheduleItem['teacher_name']}, ${scheduleItem['classroom']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: Text(
                                '${scheduleItem['week']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
