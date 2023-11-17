import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Screens/LogInScreen.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bell Exchange',
      theme: ThemeData(
        canvasColor: Colors.blueGrey.shade100,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey.shade100),
        useMaterial3: true,
      ),
      home: const LogInScreen(title: 'Main'),
    );
  }
}
