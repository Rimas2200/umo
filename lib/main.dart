import 'package:flutter/material.dart';
import 'menu/HomeScreen.dart';
import 'menu/Departament.dart';
import 'menu/Direction.dart';
import 'menu/Discipline.dart';
import 'menu/ClassRoom.dart';
import 'menu/CoupleType.dart';
import 'menu/Faculty.dart';
import 'menu/Address.dart';
import 'menu/Professor.dart';
import 'menu/GroupName.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _counter = 0;
  String _selectedMenuItem = 'Главная';

  void _onMenuItemSelected(String menuItem) {
    setState(() {
      _selectedMenuItem = menuItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  MenuItem(
                    title: 'Главная',
                    isSelected: _selectedMenuItem == 'Главная',
                    onPressed: () => _onMenuItemSelected('Главная'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Преподаватели',
                    isSelected: _selectedMenuItem == 'Преподаватели',
                    onPressed: () => _onMenuItemSelected('Преподаватели'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Дисциплины',
                    isSelected: _selectedMenuItem == 'Дисциплины',
                    onPressed: () => _onMenuItemSelected('Дисциплины'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Аудитории',
                    isSelected: _selectedMenuItem == 'Аудитории',
                    onPressed: () => _onMenuItemSelected('Аудитории'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Адреса',
                    isSelected: _selectedMenuItem == 'Адреса',
                    onPressed: () => _onMenuItemSelected('Адреса'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Типы пар',
                    isSelected: _selectedMenuItem == 'Типы пар',
                    onPressed: () => _onMenuItemSelected('Типы пар'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Кафедры',
                    isSelected: _selectedMenuItem == 'Кафедры',
                    onPressed: () => _onMenuItemSelected('Кафедры'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Факультеты',
                    isSelected: _selectedMenuItem == 'Факультеты',
                    onPressed: () => _onMenuItemSelected('Факультеты'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Направления',
                    isSelected: _selectedMenuItem == 'Направления',
                    onPressed: () => _onMenuItemSelected('Направления'),
                  ),
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Группы',
                    isSelected: _selectedMenuItem == 'Группы',
                    onPressed: () => _onMenuItemSelected('Группы'),
                  ),
                  // Add more menu items
                ],
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Container(
              color: const Color(0xFFC2C2C2),
              child: _buildSelectedScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedMenuItem) {
      case 'Главная':
        return HomeScreen(counter: _counter);
      case 'Преподаватели':
        return Professor();
      case 'Дисциплины':
        return Discipline();
      case 'Аудитории':
        return ClassRoom();
      case 'Адреса':
        return Address();
      case 'Типы пар':
        return CoupleType();
      case 'Кафедры':
        return Departament();
      case 'Факультеты':
        return Faculty();
      case 'Направления':
        return Direction();
      case 'Группы':
        return GroupName();

      default:
        return Container();
    }
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  const MenuItem({
    required this.title,
    required this.isSelected,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 0),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
        backgroundColor: isSelected ? Colors.grey[300] : const Color(0xFFF5F5F5),
        textStyle: const TextStyle(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}




