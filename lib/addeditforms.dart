// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:forms_app/widgets/forms_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AddEditForm extends StatefulWidget {
  final String? id; // Nullable to differentiate between adding and editing
  final String? name;
  final String? startDate;
  final String? endDate;
  final String? days;
  final String? status;
  final VoidCallback reloadList;

  AddEditForm({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.days,
    this.status,
    required this.reloadList,
  });

  @override
  _AddEditFormState createState() => _AddEditFormState();
}

class _AddEditFormState extends State<AddEditForm> {
  late TextEditingController nameController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController daysController;
  final CollectionReference encuestas = FirebaseFirestore.instance.collection('Encuestas');

  List<Map<String, dynamic>> activeUsers = [];
  List<bool> userSelection = [];
  bool selectAll = false;
  String selectedStatus = 'ACTIVA';
  List<String> selectedUsers = [];
  TextEditingController hoursController = TextEditingController();
  List<String> selectedEmails = [];
  final List<String> statuses = ['ACTIVA', 'CERRADA'];
  late QuerySnapshot activeUsersSnapshot;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    daysController = TextEditingController();
    hoursController.text = '0';
    _loadActiveUsers();

    if (widget.id != null) {
      setState(() {
        nameController.text = widget.name ?? '';
        startDateController.text = widget.startDate ?? '';
        endDateController.text = widget.endDate ?? '';
        daysController.text = widget.days ?? '';
        selectedStatus = widget.status ?? 'ACTIVA';
        hoursController.text = (((int.parse(daysController.text)) * 9).toString());
      });
    } else {
      setState(() {
        selectAll = true;
        // Retrieve all emails of active users
        _loadAllUserEmails();
      });
    }
  }


  Future<void> _loadAllUserEmails() async {
    // Fetch all users from the collection
    var allUsersSnapshot = await FirebaseFirestore.instance.collection('Usuarios').get();
    // Extract and store their emails in selectedEmails list
    setState(() {
      selectedEmails = allUsersSnapshot.docs.map((doc) => doc['email'].toString()).toList();
      // Populate selectedUsers with all active user IDs
      selectedUsers = allUsersSnapshot.docs.map<String>((doc) => doc.id).toList();
    });
  }

  Future<void> _loadActiveUsers() async {
    try {
      activeUsersSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .orderBy('name') // Order by 'name' field from A to Z
          .where('status', isEqualTo: 'ACTIVO')
          .where('role', isEqualTo: 'USUARIO')          
          .get();

      Map<String, String> positionNames = {};
      Map<String, String> professionNames = {};

      final CollectionReference positions = FirebaseFirestore.instance.collection('Cargos');
      final CollectionReference professions = FirebaseFirestore.instance.collection('Profesiones');
      final positionQuery = positions.get();
      final professionQuery = professions.get();
      final results = await Future.wait([positionQuery, professionQuery]);

      final positionDocs = results[0].docs;
      final professionDocs = results[1].docs;

      positionNames = {
        for (var document in positionDocs)
          document.id: (document.data() as Map<String, dynamic>)['name'] as String? ?? 'Unknown Position'
      };
      professionNames = {
        for (var document in professionDocs)
          document.id: (document.data() as Map<String, dynamic>)['name'] as String? ?? 'Unknown Profession'
      };

      setState(() {
        activeUsers = activeUsersSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('status')) {
            data ??= {};
            data['status'] = 'NO ASIGNADA';
          }

          String positionName = positionNames[data['position']] ?? 'Unknown Position';
          String professionName = professionNames[data['profession']] ?? 'Unknown Profession';

          data['positionName'] = positionName;
          data['professionName'] = professionName;

          return data;
        }).toList();

        userSelection = List<bool>.filled(activeUsers.length, false);

        if (widget.id != null) {
          _loadSelectedUsers(widget.id!);
        } else {
          userSelection = List<bool>.filled(activeUsers.length, true);
        }
      });
    } catch (e) {
      print('Error loading active users: $e');
      // Handle the error, e.g., show a Snackbar or an alert
    }
  }



  Future<void> _loadSelectedUsers(String id) async {
    var selectedUsersSnapshot = await FirebaseFirestore.instance
        .collection('Encuestas')
        .doc(id)
        .collection('Usuarios')
        .get();
    var selectedUsersIds = selectedUsersSnapshot.docs.map((doc) => doc.id).toList();

    setState(() {
      for (int i = 0; i < activeUsers.length; i++) {
        if (selectedUsersIds.contains(activeUsersSnapshot.docs[i].id)) {
          userSelection[i] = true;
          selectedUsers.add(activeUsersSnapshot.docs[i].id);
          selectedEmails.add(activeUsers[i]['email']); // Add the email to the list
        }
      }
    });
  }


  Future<void> manualSendEmail(List<String> recipients, String body) async {
    String subject = "Invitación a resolver la encuesta ${nameController.text}";
    final String _recipients = recipients.join(',');

    final String encodedSubject = Uri.encodeComponent(subject);
    final String encodedBody = Uri.encodeComponent(body);

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _recipients,
      query: 'subject=$encodedSubject&body=$encodedBody',
    );

    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  List<String> allRecipients = [];
  List<String> finalRecipients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.id != null ? 'EDITAR ENCUESTA' : 'AGREGAR ENCUESTA')),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(300, 50, 300, 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              buildTextField('NOMBRE', nameController, false),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: buildDateField('FECHA DE INICIO', startDateController, context)),
                  SizedBox(width: 10),
                  Expanded(child: buildDateField('FECHA DE FINALIZACIÓN', endDateController, context)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 600,
                      child: TextFormField(
                        controller: daysController,
                        readOnly: false,
                        decoration: InputDecoration(
                          labelText: 'DÍAS HÁBILES',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                        onChanged: (value) {
                          int horas = int.parse(value) * 9;
                          hoursController.text = horas.toString();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: buildTextField('HORAS ESPERADAS', hoursController, true),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: buildDropdownField(
                      'ESTADO',
                      statuses,
                      (value) {
                        setState(() {
                          selectedStatus = value ?? 'ACTIVA';
                        });
                      },
                      initialValue: selectedStatus,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'NOMBRE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'PROFESIÓN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'CARGO',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'SEDE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'ESTADO',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(flex: 1, child: SizedBox())
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('SELECCIONAR TODOS'),
                  Checkbox(
                    value: selectAll,
                    onChanged: (bool? value) {
                      setState(() {
                        selectAll = value ?? false;
                        userSelection = List<bool>.filled(activeUsers.length, selectAll);
                        selectedEmails.clear(); // Clear the list to avoid duplication
                        selectedUsers.clear(); // Clear the selected users list
                        if (selectAll) {
                          // If "Select All" is checked, add all user IDs to the list
                          selectedUsers.addAll(activeUsers
                            .where((user) => user.containsKey('userId') && user['userId'] != null)
                            .map((user) => user['userId']!));
                          // Also add all emails to the list
                          selectedEmails.addAll(activeUsers.map((user) => user['email']));
                        }
                      });
                    },
                  ),
                ],
              ),
              Divider(),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: activeUsers.length,
                  itemBuilder: (context, index) {
                    var user = activeUsers[index];
                    var userId = activeUsersSnapshot.docs[index].id;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 4, child: Text(user['name'] ?? '')),
                            Expanded(flex: 4, child: Text(user['professionName'])),
                            Expanded(flex: 4, child: Text(user['positionName'])),
                            Expanded(flex: 4, child: Text(user['sede'] ?? '')),
                            Expanded(flex: 1, child: Text(user['status'] ?? 'NO ASIGNADA')),
                            Expanded(
                              flex: 1,
                              child: Checkbox(
                                value: userSelection[index],
                                onChanged: (bool? selected) {
                                  setState(() {
                                    userSelection[index] = selected!;
                                    if (selected) {
                                      selectedUsers.add(userId);
                                      selectedEmails.add(activeUsers[index]['email']);
                                    } else {
                                      selectedUsers.remove(userId);
                                      selectedEmails.remove(activeUsers[index]['email']);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider()
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 30),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _saveOrEditSurvey();
                },
                child: Text('GUARDAR ENCUESTA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    if (nameController.text.isEmpty ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty ||
        daysController.text.isEmpty ||
        hoursController.text.isEmpty ||
        selectedStatus.isEmpty) {
      return false;
    }
    return true;
  }

  void _saveOrEditSurvey() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('POR FAVOR, COMPLETE TODOS LOS CAMPOS')),
      );
      return;
    }

    if (widget.id != null) {
      await _updateSurvey();
      print(selectedEmails);
      const String body = '''
          Hola, el área técnica de CyMA te invita a responder la última encuesta, copia y pega el siguiente link en tu navegador para visitar la plataforma de Encuestas MOP.

          https://javierrueda7.github.io/CYMA-EncuestasMOP/

          Cordial saludo,

          Equipo CyMA - Encuestas MOP          
          ''';
      manualSendEmail(selectedEmails, body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡ENCUESTA ACTUALIZADA EXITOSAMENTE!')),
      );
    } else {
      // Check if any users are selected
      if (selectedUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('POR FAVOR, SELECCIONE AL MENOS UN USUARIO')),
        );
        return;
      }
      
      await _addSurvey();
      print(selectedEmails);
      const String body = '''
          Hola, el área técnica de CyMA te invita a responder la última encuesta, copia y pega el siguiente link en tu navegador para visitar la plataforma de Encuestas MOP.

          https://javierrueda7.github.io/CYMA-EncuestasMOP/

          Cordial saludo,

          Equipo CyMA - Encuestas MOP
          ''';
      manualSendEmail(selectedEmails, body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡ENCUESTA CREADA EXITOSAMENTE!')),
      );
    }

    widget.reloadList();
    Navigator.pop(context);
  }


  Future<void> _addSurvey() async {
    String id = await idGenerator(encuestas, 'Encuestas');
    var newSurveyDoc = FirebaseFirestore.instance.collection('Encuestas').doc(id);
    await newSurveyDoc.set({
      'name': nameController.text,
      'startDate': startDateController.text,
      'endDate': endDateController.text,
      'days': daysController.text,
      'status': selectedStatus,
      'hours': hoursController.text,
    });

    // Retrieve the selected user IDs
    List<String> selectedUserIds = userSelection.asMap().entries.where((entry) => entry.value).map((entry) => activeUsersSnapshot.docs[entry.key].id).toList();

    for (var userId in selectedUserIds) {
      await newSurveyDoc.collection('Usuarios').doc(userId).set({
        'status': 'ACTIVO',
      });
    }
  }


  Future<void> _updateSurvey() async {
    var surveyDoc = FirebaseFirestore.instance.collection('Encuestas').doc(widget.id);
    await surveyDoc.update({
      'name': nameController.text,
      'startDate': startDateController.text,
      'endDate': endDateController.text,
      'days': daysController.text,
      'status': selectedStatus,
      'hours': hoursController.text,
    });

    var userCollection = surveyDoc.collection('Usuarios');
    var currentUsers = await userCollection.get();

    for (var doc in currentUsers.docs) {
      if (!selectedUsers.contains(doc.id)) {
        await userCollection.doc(doc.id).delete();
      }
    }

    for (var userId in selectedUsers) {
      if (!currentUsers.docs.any((doc) => doc.id == userId)) {
        await userCollection.doc(userId).set({
          'status': 'ACTIVO',
        });
      }
    }
  }
}
