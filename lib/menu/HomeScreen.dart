import 'package:flutter/material.dart';
import 'package:umo/Schedule.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.counter, Key? key}) : super(key: key);

  final int counter;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedFaculty;

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
                children: [
                  FacultyButton(
                    title: 'Математический факультет',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Математический факультет';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2),
                  FacultyButton(
                    title: 'Институт информационных технологий',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Институт информационных технологий';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2),
                  FacultyButton(
                    title: 'Физический факультет',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Физический факультет';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
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
  final VoidCallback onPressed;

  const FacultyButton({required this.title, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
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


