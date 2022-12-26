import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_drug_survey_application/models/model_auth.dart';

class MedicineTab extends StatefulWidget {
  const MedicineTab({Key? key}) : super(key: key);

  @override
  _MedicineTabState createState() => _MedicineTabState();
}

class _MedicineTabState extends State<MedicineTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberOfdoesController = TextEditingController();
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('medicine');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _numberOfdoesController.text = documentSnapshot['does'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'サプリメント名'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _numberOfdoesController,
                  decoration: const InputDecoration(labelText: '１日服用回数'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? '追加' : '更新'),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final double? does =
                        double.tryParse(_numberOfdoesController.text);

                    DateTime dt = DateTime.now();

                    final String? today = dt.year.toString() +
                        '-' +
                        dt.month.toString() +
                        '-' +
                        dt.day.toString();

                    if (name != null && does != null) {
                      if (action == 'create') {
                        final authClient = Provider.of<FirebaseAuthProvider>(
                            context,
                            listen: false);
                        await _products.add({
                          "name": name,
                          "does": does,
                          "email": authClient.user!.email!,
                          "RegisterDay": today,
                          "takeTime": "",
                        });

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.blueAccent,
                            content: Text(
                              '${name}を追加しました！',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white),
                            )));
                      }

                      if (action == 'update') {
                        await _products
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "does": does});

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                backgroundColor: Colors.yellowAccent,
                                content: Text(
                                  '情報を更新しました！',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87),
                                )));
                      }
                      _nameController.text = '';
                      _numberOfdoesController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _deleteProduct(String productId) async {
    await _products.doc(productId).delete();
    await _products.doc(productId).update({"takeTime": ''});

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          '削除しました！',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        )));
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
                    if (documentSnapshot['email'].toString() ==
                        authClient.user!.email!) {
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(documentSnapshot['name']
                              .toString()
                              .replaceAll(".0", "")),
                          subtitle: Text("１日服用回数:" +
                              documentSnapshot['does']
                                  .toString()
                                  .replaceAll(".0", "")),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    color: Colors.deepOrange[400],
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _createOrUpdate(documentSnapshot)),
                                IconButton(
                                    color: Colors.red[700],
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteProduct(documentSnapshot.id)),
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black87,
          onPressed: () => _createOrUpdate(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
