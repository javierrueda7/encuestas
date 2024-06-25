import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/form.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:intl/intl.dart';

class ListUserForms extends StatefulWidget {
  final String uid;

  ListUserForms({super.key, required this.uid});

  @override
  // ignore: library_private_types_in_public_api
  _ListUserFormsState createState() => _ListUserFormsState();
}

class _ListUserFormsState extends State<ListUserForms> {
  
  late String uid;

  @override
  void initState() {
    uid = widget.uid;
    super.initState();
  }

  void _reloadList() {
    setState(() {}); // Empty setState just to trigger rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('ENCUESTAS')),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(350, 50, 350, 50),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ENCUESTAS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ESTADO',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ), // Add spacing between header and FutureBuilder
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: getEncuestasUser(uid),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data?[index];
                        return ListTile(
                          leading: Text(item?['id'], style: TextStyle(fontSize: 16),),
                          title: Text(item?['data']['name']),
                          subtitle: Text(item?['data']['startDate'] + ' - ' + item?['data']['endDate']),
                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                item?['user']['status'] != 'ABIERTA' ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item?['user']['status'], style: TextStyle(fontSize: 14),),
                                    Text(DateFormat('dd-MM-yyyy HH:mm').format(item?['user']['date'].toDate()), style: TextStyle(fontSize: 12),)
                                  ],
                                ) : Text(item?['data']['status'], style: TextStyle(fontSize: 14),),
                                SizedBox(width: 8,),
                                IconButton(onPressed: () {
                                  if(item?['data']['status'] == 'ACTIVA'){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => FormsPage(
                                        idForm: item?['id'], // Accessing the document ID
                                        formName: item?['data']['name'],
                                        dates: item?['data']['startDate'] + ' - ' + item?['data']['endDate'],
                                        uidUser: uid,
                                        hours: ((int.parse(item?['data']['days']))*9).toString(),
                                        formState: item?['user']['status'],
                                        answers: item?['user']['status'] == 'ABIERTA' ?  'NULL' : item?['user']['answer'],
                                        date: item?['user']['status'] == 'ABIERTA' ? DateTime.now() : (item?['user']['date'] as Timestamp).toDate(),
                                        reloadList: _reloadList,
                                      )), // Navigate to the NewUserPage
                                    );
                                  } else if(item?['user']['status'] == 'ENVIADA'){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('La encuesta ya ha sido respondida.'),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                }, icon: item?['user']['status'] == 'ENVIADA' ? Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent,) : Icon(Icons.edit, color: Colors.blueAccent))
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


