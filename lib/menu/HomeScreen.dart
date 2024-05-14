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
                  const SizedBox(height: 2),
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
                  const SizedBox(height: 2),
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
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Химический факультет',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Химический факультет';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Биологический факультет',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Биологический факультет';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Институт права',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Институт права';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Экономический факультет',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Экономический факультет';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Факультет управления',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Факультет управления';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Институт экономики отраслей',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Институт экономики отраслей';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Факультет фундаментальной медицины',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Факультет фундаментальной медицины';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Институт образования и практической психологии',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Институт образования и практической психологии';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Факультет Евразии и Востока',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Факультет Евразии и Востока';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Факультет лингвистики и перевода',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Факультет лингвистики и перевода';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Факультет журналистики',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Факультет журналистики';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Историко-филологический факультет',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Историко-филологический факультет';
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(selectedFaculty: selectedFaculty),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  FacultyButton(
                    title: 'Факультет экологии',
                    onPressed: () {
                      setState(() {
                        selectedFaculty = 'Факультет экологии';
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


