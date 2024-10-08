import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
import 'menu/Positions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Расписание ЧелГУ',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  String baseUrl = '';
  int port = 0;

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  Future<void> loadConfig() async {
    try {
      String content = await DefaultAssetBundle.of(context).loadString('assets/config.json');
      Map<String, dynamic> config = jsonDecode(content);
      baseUrl = config['baseUrl'];
      port = config['port'];
    } catch (e) {
      print('Ошибка при загрузке конфигурационного файла: $e');
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    final Map<String, String> requestBody = {
      'email': email,
      'password': password,
    };

    final Uri url = Uri.parse('$baseUrl:$port/authUmo');

    try {
      final http.Response response = await http.post(
        url,
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String token = responseData['token'];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter Demo Home Page')),
        );
      } else {
        final String errorMessage = responseData['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      print('Ошибка: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авторизация'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              child: Text('Войти'),
            ),
          ],
        ),
      ),
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
                  const SizedBox(height: 10),
                  MenuItem(
                    title: 'Должности',
                    isSelected: _selectedMenuItem == 'Должности',
                    onPressed: () => _onMenuItemSelected('Должности'),
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
      case 'Должности':
        return Positions();
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
