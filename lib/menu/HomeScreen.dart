import 'package:flutter/material.dart';
import 'package:umo/Schedule.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.counter, Key? key}) : super(key: key);

  final int counter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        color: const Color(0xFFC2C2C2),
        padding: const EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Выберете ваш факультет/институт',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView(
                children: const [
                  FacultyButton(title: 'Математический факультет'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Институт информационных технологий'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Физический факультет'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Химический факультет'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Биологический факультет'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Институт права'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Экономический факультет'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Факультет управления'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Институт экономики отраслей'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Факультет фундаментальной медицины'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Институт образования и практической психологии'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Факультет Евразии и Востока'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Факультет лингвистики и перевода'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Факультет журналистики'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Историко-филологический факультет'),
                  SizedBox(height: 1.0),
                  FacultyButton(title: 'Факультет экологии'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FacultyButton extends StatelessWidget {
  final String title;

  const FacultyButton({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Schedule()),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black38, backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(title),
    );
  }
}

