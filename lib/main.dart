import 'package:equip_manager/admin/AdminMainPage.dart';
import 'package:equip_manager/user/SharedPreferenceService.dart';
import 'package:equip_manager/user/home_page.dart';
import 'package:equip_manager/user/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferenceService service = SharedPreferenceService();
  bool state = false;
  bool isUser = true;

  wait() async {
    var data = await service.getData('auth');
    print(data);
    isUser = data['role'] == 'user';
    setState(() {
      state = data.isEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    wait();
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
          state
              ? LoginPage()
              : isUser
              ? HomePage()
              : Adminmainpage(),
    );
  }
}
