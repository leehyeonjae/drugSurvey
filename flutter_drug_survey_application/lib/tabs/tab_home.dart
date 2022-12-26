import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_drug_survey_application/models/model_auth.dart';

final List<String> list = [];

class HomeTab extends StatelessWidget {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('medicine');

  Future<void> _sendUpdate([DocumentSnapshot? documentsSnapshot]) async {
    DateTime dt = DateTime.now();
    String takeTime = dt.year.toString() +
        '_' +
        dt.month.toString() +
        '_' +
        dt.day.toString() +
        '_' +
        dt.hour.toString() +
        '_' +
        dt.minute.toString() +
        '_' +
        dt.second.toString();
    await _products.doc(documentsSnapshot!.id).update({
      "takeTime": FieldValue.arrayUnion([takeTime])
    });
  }

  @override
  Widget build(BuildContext context) {
    final authClient =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: _products.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    DateTime dt = DateTime.now();
                    int count = 0;
                    for (var i = 0;
                        i < documentSnapshot['takeTime'].length;
                        i++) {
                      String today = dt.year.toString() +
                          '_' +
                          dt.month.toString() +
                          '_' +
                          dt.day.toString();
                      if (documentSnapshot['takeTime'][i]
                          .toString()
                          .startsWith(today)) {
                        count++;
                      }
                    }

                    if (documentSnapshot['email'].toString() ==
                        authClient.user!.email!) {
                      return Card(
                        margin: const EdgeInsets.all(20),
                        child: ListTile(
                          title: Text(documentSnapshot['name'].toString()),
                          subtitle: Text("１日服用回数　：　" +
                              documentSnapshot['does']
                                  .toString()
                                  .replaceAll(".0", "") +
                              "    服用した回数　：　" +
                              count.toString()),
                          trailing: SizedBox(
                            width: 50,
                            child: Row(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                      color: Colors.deepOrange[400],
                                      icon: const Icon(Icons.send),
                                      onPressed: () =>
                                          _sendUpdate(documentSnapshot)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Card();
                    }
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
