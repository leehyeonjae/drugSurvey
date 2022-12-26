import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_drug_survey_application/models/model_auth.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(authClient.user!.email! + '様\n'),
        Text('こんにちは😻'),
        TextButton(
          onPressed: () async {
            await authClient.logout();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('サインアウトされました')),
              );
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Text('サインアウト'),
        ),
      ],
    ));
  }
}
