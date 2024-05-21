import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class TimetableGroup extends StatefulWidget {
  final String selectedGroup;
  final List<String> directions;

  const TimetableGroup({Key? key, required this.selectedGroup, required this.directions}) : super(key: key);

  @override
  _TimetableGroupState createState() => _TimetableGroupState();
}

class _TimetableGroupState extends State<TimetableGroup> {
  late Future<List<Map<String, dynamic>>> _futureGroupSchedule;
  List<String> _groups = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureGroupSchedule = fetchGroupSchedule(widget.selectedGroup);
  }

  Future<Map<String, dynamic>> _loadConfig() async {
    final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/config.json');
    return jsonDecode(jsonString);
  }

  Future<void> fetchGroups(String directionId) async {
    try {
      final config = await _loadConfig();
      final response = await http.get(Uri.parse('${config['baseUrl']}:${config['port']}/group_name/$directionId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(data);
        if (data.isNotEmpty) {
          setState(() {
            _groups = data.map((item) => item['name'] as String).toList();
          });
        }
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (error) {}
  }

  Future<List<Map<String, dynamic>>> fetchGroupSchedule(String groupName) async {
    try {
      final config = await _loadConfig();
      final response =
      await http.get(Uri.parse('${config['baseUrl']}:${config['port']}/schedule/group?group_name=$groupName'));
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

  void _onFacultyPressed() {
  }

  void _onDirectionPressed() {
  }

  void _onRefreshPressed() {
    setState(() {
      _futureGroupSchedule = fetchGroupSchedule(widget.selectedGroup);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_book),
              tooltip: 'Выбор направления',
              itemBuilder: (BuildContext context) {
                return widget.directions.map((direction) {
                  return PopupMenuItem<String>(
                    value: direction,
                    child: Text(direction),
                  );
                }).toList();
              },
              onSelected: (String value) async {
                try {
                  await fetchGroups(value);
                } catch (error) {}
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _onRefreshPressed,
              tooltip: 'Обновить',
            ),
            Spacer(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: _buildGroupColumns(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildGroupColumns() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Scrollbar(
            trackVisibility: true,
            controller: _scrollController,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: _groups.length,
              itemBuilder: (BuildContext context, int index) {
                String groupName = _groups[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        groupName,
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    width: _calculateGroupWidth(groupName),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  double _calculateGroupWidth(String groupName) {
    final textWidth = TextPainter(
      text: TextSpan(text: groupName, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();

    return textWidth.width + 400.0;
  }
}
