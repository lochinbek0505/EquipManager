import 'package:equip_manager/admin/AdminMainPage.dart';
import 'package:equip_manager/user/SharedPreferenceService.dart';
import 'package:equip_manager/user/home_page.dart';
import 'package:equip_manager/user/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SharedPreferenceService _service = SharedPreferenceService();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isUser = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      var data = await _service.getData('auth');
      print(data);
      if (data != null && data.isNotEmpty) {
        _isUser = data['role'] == 'user';
        _isLoggedIn = true;
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          _isLoading
              ? Scaffold(body: Center(child: CircularProgressIndicator()))
              : _isLoggedIn
              ? (_isUser ? HomePage() : Adminmainpage())
              : LoginPage(),
    );
  }
}
