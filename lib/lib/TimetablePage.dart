import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class TimetablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Шахматка'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Функция находится в разработке.',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}
// class TimetablePage extends StatefulWidget {
//   @override
//   _TimetablePageState createState() => _TimetablePageState();
// }
//
// class _TimetablePageState extends State<TimetablePage> {
//   List<List<String>> timetable = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     final MySqlConnection conn = await MySqlConnection.connect(
//       ConnectionSettings(
//         host: '127.0.0.1',
//         port: 3306,
//         user: 'root',
//         password: '',
//         db: 'timetable',
//       ),
//     );
//
//     final List<String> arrayDay = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'];
//
//     final List<List<String>> tempList = [];
//     for (final day in arrayDay) {
//       final Results results = await conn.query('SELECT * FROM timetable WHERE day_of_the_week = ?', [day]);
//       final List<String> classroomList = [];
//       results.forEach((row) {
//         final classroom = row['classroom'];
//         final subject = row['subject'];
//         final lessonType = row['lesson_type'];
//         final lessonNumber = row['lesson_number'];
//         if (classroom != ' ' && lessonType != 'None') {
//           if (lessonType == '0') {
//             classroomList[(int.parse(lessonNumber) * 2) - 1] = subject;
//             classroomList[int.parse(lessonNumber) * 2] = subject;
//           } else if (lessonType == '1Н') {
//             classroomList[(int.parse(lessonNumber) * 2) - 1] = subject;
//           } else if (lessonType == '2Н') {
//             classroomList[int.parse(lessonNumber) * 2] = subject;
//           }
//         }
//       });
//       tempList.add(classroomList);
//     }
//
//     setState(() {
//       timetable = tempList;
//     });
//
//     await conn.close();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Timetable'),
//       ),
//       body: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           child: DataTable(
//             columns: _buildColumns(),
//             rows: _buildRows(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<DataColumn> _buildColumns() {
//     return [
//       DataColumn(label: Text('Семестр')),
//       DataColumn(label: Text('Учебный год')),
//       for (var i = 0; i < 6; i++) DataColumn(label: Text('Classroom $i')),
//     ];
//   }
//
//   List<DataRow> _buildRows() {
//     final List<DataRow> rows = [];
//     for (var i = 0; i < 12; i++) {
//       final List<DataCell> cells = [
//         DataCell(Text('')),
//         DataCell(Text('')),
//         for (var j = 0; j < 6; j++) DataCell(Text(timetable[j][i] ?? '')),
//       ];
//       rows.add(DataRow(cells: cells));
//     }
//     return rows;
//   }
// }
