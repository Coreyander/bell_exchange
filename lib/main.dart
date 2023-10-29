import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Screens/LogInScreen.dart';
import 'firebase_options.dart';

void main() {
  try {
    initFirebase();
  } catch(error) {
    if (kDebugMode) {
      print('Exception occurred: Could not initialize firebase to the app. Cloud data is not supported until this is resolved');
    }
  }
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

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
