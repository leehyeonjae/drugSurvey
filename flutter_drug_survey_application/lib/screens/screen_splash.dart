import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_drug_survey_application/models/model_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authClient =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    bool isLogin = prefs.getBool('isLogin') ?? false;
    print("[*] Logging... : " + isLogin.toString());
    if (isLogin) {
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');
      print("[*] Retry login saved information");
      try {
        await authClient.loginWithEmail(email!, password!).then((loginStatus) {
          if (loginStatus == AuthStatus.loginSuccess) {
            print("[+] login Success");
          } else {
            print("[-] login failed");
            isLogin = false;
            prefs.setBool('isLogin', false);
          }
        });
      } catch (e) {
        print(e);
        print("Null Error?");
      }
    }
    return isLogin;
  }

  void moveScreen() async {
    await checkLogin().then((isLogin) {
      if (isLogin) {
        Navigator.of(context).pushReplacementNamed('/index');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 1500), () {
      moveScreen();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Text('Supplement Survey Screen'),
      ),
    );
  }
}
