import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nursery/View/User-auth/Sign-up.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SignupPage(),
    );
  }
}
