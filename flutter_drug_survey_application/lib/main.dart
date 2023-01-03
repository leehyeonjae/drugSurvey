import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_drug_survey_application/models/model_auth.dart';

import 'package:flutter_drug_survey_application/screens/screen_splash.dart';
import 'package:flutter_drug_survey_application/screens/screen_login.dart';
import 'package:flutter_drug_survey_application/screens/screen_index.dart';
import 'package:flutter_drug_survey_application/screens/screen_register.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
      ],
      child: MaterialApp(
        title: 'Supplement Survey App',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/index': (context) => IndexScreen(),
          '/register': (context) => RegisterScreen(),
          //'/medicine_register': (context) => medicine_RegisterScrPeen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
