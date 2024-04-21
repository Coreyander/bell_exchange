import 'package:bell_exchange/Screens/ExchangeScreen.dart';
import 'package:bell_exchange/screens/ChatroomScreen.dart';
import 'package:bell_exchange/screens/EditProfileScreen.dart';
import 'package:bell_exchange/screens/MessagesScreen.dart';
import 'package:bell_exchange/screens/ProfileScreen.dart';
import 'package:bell_exchange/screens/SignUpSplashScreen.dart';
import 'package:bell_exchange/screens/SplashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Screens/LogInScreen.dart';
import 'Screens/SettingsScreen.dart';
import 'database/messenger/chatroom.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Hi me... we coded to 3 am LOL anyway, you're doing great I just
/// wanted to tell you that you need to test Firebase to ensure ScheduleEntry.utils().getScheduleMasterList parses from Firebase correctly
/// Then you need to make the cards in the Exchange Page for all posted shifts. Afterwards you can move on to creating the filters!
///
///

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes:{
        '/login': (context) => const LogInScreen(title: 'title'),
        '/exchange': (context) => const ExchangeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/signUpSplash': (context) =>  const SignUpSplash(path: 1),
        '/chatroom': (context) => ChatroomScreen(room: Chatroom('','','')),
        '/messages': (context) => const MessagesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/editProfile': (context) => const EditProfileScreen(),
      },
      title: 'Bell Exchange',
      theme: ThemeData(
        canvasColor: Colors.blueGrey.shade100,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey.shade100),
        useMaterial3: true,
         // Adjust header padding

      ),
      home: const SplashScreen(title: 'Main'),
    );
  }
}
