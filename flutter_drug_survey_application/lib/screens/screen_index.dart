import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_drug_survey_application/tabs/tab_home.dart';
import 'package:flutter_drug_survey_application/tabs/tab_profile.dart';
import 'package:flutter_drug_survey_application/tabs/tab_medcine.dart';

class IndexScreen extends StatefulWidget {
  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  // Firebase messaging recieve
  String? mToken = "";
  late String _message;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final HttpsCallable firebaseMessaginSendingBycloudfunctions =
      FirebaseFunctions.instance.httpsCallable(
    'function-2',
    options: HttpsCallableOptions(
      timeout: const Duration(seconds: 5),
    ),
  );

  //INDEX
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    HomeTab(),
    MedicineTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _message = "";
    //getMessage();
    requestPermission();
    getToken();
    initInfo();
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse: (NotificationResponse res) async {
      debugPrint('payload:${res.payload}');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(
          ".............................onMessage............................");
      print(
          "onMessage: ${message.notification?.title}/${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContent: true,
      );
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'dbfood',
        'dbfood',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mToken = token;
        print("My token is $mToken");
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("UserTokens").doc("User1").set({
      'token': token,
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission: ${settings.authorizationStatus}');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisionla permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // void sendPushMessage(String token, String body, String title) async {
  //   if (token == null) {
  //     print('Unable to send FCM message, no token exists.');
  //   }

  //   try {
  //     await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization':
  //             'AAAA5hO9928:APA91bHNcnxxnSuwQ1-Qd-dt4hhIrVtAbaEvbGP-cPA93i-T1vV5gczuBQcDNKSQJVyQX9xPpFH8bGHG0N3cQan7JbrVgdnDtPpuOfNtWCSWtCFLzskDgN0i8GQwTlI2nFfW9-y_Iv0W'
  //       },
  //       body: jsonEncode(<String, dynamic>{
  //         'priority': 'high',
  //         'data': <String, dynamic>{
  //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //           'status': 'done',
  //           'body': body,
  //           'title': title,
  //         },
  //         "notofication": <String, dynamic>{
  //           "title": title,
  //           "body": body,
  //           "android_channel_id": "dbfood"
  //         },
  //         "to": token,
  //       }),
  //     );
  //     print("FCM request for device sent!");
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // void getMessage() async {
  //   String url =
  //       'https://us-central1-fcmapp-63b00.cloudfunctions.net/function-2';
  //   var response = await http.get(Uri.parse(url));
  //   setState(() {
  //     String messageTest = "";
  //     messageTest = response.body;
  //     print(messageTest);
  //     _message = messageTest;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supplement Survey'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 12),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'メイン'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: '薬登録'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'アカウント'),
        ],
      ),
      body: _tabs[_currentIndex],
    );
  }
}
