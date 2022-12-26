import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_drug_survey_application/models/model_auth.dart';
import 'package:flutter_drug_survey_application/models/model_login.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginFieldModel(),
      child: Scaffold(
        appBar: AppBar(title: Text("サインイン")),
        body: Column(
          children: [
            EmailInput(),
            PasswordInput(),
            RegisterNumberInput(),
            LoginButton(),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 1),
            ),
            RegisterButton(),
          ],
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginField = Provider.of<LoginFieldModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        onChanged: (email) {
          loginField.setEmail(email);
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'メールアドレス',
          helperText: '',
        ),
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginField = Provider.of<LoginFieldModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        onChanged: (password) {
          loginField.setPassword(password);
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'パスワード',
          helperText: '',
        ),
      ),
    );
  }
}

class RegisterNumberInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginField = Provider.of<LoginFieldModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        onChanged: (registerNumber) {
          loginField.setRegisternumber(registerNumber);
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: '登録番号',
          helperText: '',
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    final loginField = Provider.of<LoginFieldModel>(context, listen: false);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        )),
        onPressed: () async {
          await authClient
              .loginWithEmail(loginField.email!, loginField.password!)
              .then((loginStatus) {
            if (loginStatus == AuthStatus.loginSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(authClient.user!.email! + '様　ようこそ！')),
                );
              Navigator.pushReplacementNamed(context, '/index');
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('ログインができませんでした。もう一度お試しください')),
                );
            }
          });
        },
        child: Text('サインイン'),
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/register');
      },
      child: Text(
        'メールアドレスで簡単登録',
        style: TextStyle(color: theme.primaryColor),
      ),
    );
  }
}
