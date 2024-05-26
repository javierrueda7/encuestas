import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:forms_app/widgets/forms_widgets.dart';

class AddEditForm extends StatefulWidget {
  final String? id; // Nullable to differentiate between adding and editing
  final String? name;
  final String? startDate;
  final String? endDate;
  final String? days;
  final String? status;
  final VoidCallback reloadList;

  AddEditForm({this.id, this.name, this.startDate, this.endDate, this.days, this.status, required this.reloadList});

  @override
  // ignore: library_private_types_in_public_api
  _AddEditFormState createState() => _AddEditFormState();
}

class _AddEditFormState extends State<AddEditForm> {
  late TextEditingController nameController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController daysController;

  List<Map<String, dynamic>> activeUsers = []; // Corrected type declaration
  List<bool> userSelection = [];
  bool selectAll = false;
  String selectedStatus = 'ACTIVA';
  List<String> selectedUsers = [];
  TextEditingController hoursController = TextEditingController();

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
        selectedStatus = widget.status ?? '';
        hoursController.text = (((int.parse(daysController.text))*9).toString());
      });
      _loadSelectedUsers(widget.id!);
    }
  }

  Future<void> _loadActiveUsers() async {
    // Fetch active users snapshot
    activeUsersSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .where('status', isEqualTo: 'ACTIVO')
        .get();
    
    // Initialize position and profession names maps
    Map<String, String> positionNames = {};
    Map<String, String> professionNames = {};

    // Fetch positions and professions concurrently
    final CollectionReference positions = FirebaseFirestore.instance.collection('Cargos');
    final CollectionReference professions = FirebaseFirestore.instance.collection('Profesiones');
    final positionQuery = positions.get();
    final professionQuery = professions.get();

    // Wait for both queries to complete
    final results = await Future.wait([positionQuery, professionQuery]);

    // Extract position and profession documents
    final positionDocs = results[0].docs;
    final professionDocs = results[1].docs;

    // Create maps to store position and profession names
    positionNames = {
      for (var document in positionDocs)
        document.id: (document.data() as Map<String, dynamic>)['name'] as String? ?? 'Unknown Position'
    };
    professionNames = {
      for (var document in professionDocs)
        document.id: (document.data() as Map<String, dynamic>)['name'] as String? ?? 'Unknown Profession'
    };

    // Set activeUsers state
    setState(() {
      activeUsers = activeUsersSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>?;

        // Check if data is null or 'status' field is not present
        if (data == null || !data.containsKey('status')) {
          // Set 'status' field to default value 'NO ASIGNADA'
          data ??= {};
          data['status'] = 'NO ASIGNADA';
        }

        // Fetch position and profession names
        String positionName = positionNames[data['position']] ?? 'Unknown Position';
        String professionName = professionNames[data['profession']] ?? 'Unknown Profession';

        // Add position and profession names to the data map
        data['positionName'] = positionName;
        data['professionName'] = professionName;

        return data;
      }).toList();
      userSelection = List<bool>.filled(activeUsers.length, false);
    });
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
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    hoursController.addListener(() {
      final text = hoursController.text.toUpperCase();
      if (hoursController.text != text) {
        hoursController.value = hoursController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
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
                  Expanded(child: SizedBox(
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
                        int horas = int.parse(value)*9;
                        hoursController.text = horas.toString();
                      },
                    ),
                  ),            ),
                  SizedBox(width: 10),
                  Expanded(
                    child: buildTextField('HORAS ESPERADAS', hoursController, true),
                  ),                
                  SizedBox(width: 10),
                  Expanded(
                    child: buildDropdownField(
                      'Estado',
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
                      child: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold),)
                    ),                       
                    Expanded(
                      flex: 4,
                      child: Text('PROFESIÓN', style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
                    Expanded(
                      flex: 4,
                      child: Text('CARGO', style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
                    Expanded(
                      flex: 4,
                      child: Text('SEDE', style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('ESTADO', style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox()
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              Container(
                constraints: BoxConstraints(maxHeight: 400, maxWidth: 800),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: activeUsers.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(activeUsers[index]['name'])
                          ),                       
                          Expanded(
                            flex: 3,
                            child: Text('${activeUsers[index]['professionName']}')
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('${activeUsers[index]['positionName']}')
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(activeUsers[index]['sede'])
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(activeUsers[index]['status'])
                          )
                        ],
                      ),
                      value: userSelection[index],
                      onChanged: (bool? value) {
                        setState(() {
                          userSelection[index] = value ?? false;
                        });
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectAll = !selectAll;
                        userSelection = List<bool>.filled(activeUsers.length, selectAll);
                      });
                    },
                    child: Text(selectAll ? 'DESELECCIONAR TODO' : 'SELECCIONAR TODO'),
                  ),
                  buildButton('GUARDAR', Colors.green, () {
                    if (widget.id != null) {
                      _updateForm();
                    } else {
                      _saveForm();
                    }
                  }),
                  buildButton('CANCELAR', Colors.red, () => Navigator.pop(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveForm() async {
    for (int i = 0; i < activeUsers.length; i++) {
      if (userSelection[i]) {
        selectedUsers.add(activeUsersSnapshot.docs[i].id);
      }
    }
    if (_validateFields()) {
      try {
        CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Encuestas');
        // Add the main document to 'Encuestas' collection
        String id = await idGenerator(collectionReference, 'Encuestas');
        collectionReference.doc(id).set({
          'name': nameController.text,
          'startDate': startDateController.text,
          'endDate': endDateController.text,
          'days': daysController.text,
          'status': selectedStatus,
        }).then((mainDocRef) async {
          // Add subcollection 'Usuarios' and documents for each selected user
          for (String userId in selectedUsers) {
            await collectionReference.doc(id).collection('Usuarios').doc(userId).set({
              'status': 'ACTIVO',
            });
          }
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Encuesta guardada exitosamente.'),
            duration: Duration(seconds: 4),
          ),
        );

        nameController.clear();
        startDateController.clear();
        endDateController.clear();
        daysController.clear();

        widget.reloadList();

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } catch (e) {
        // Handle errors
        print('Error saving user: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el usuario. Por favor, inténtelo de nuevo más tarde.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      // Show error message if fields are incomplete or invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, complete todos los campos correctamente.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  bool _validateFields() {
    if (nameController.text.isEmpty ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty ||
        daysController.text.isEmpty ||
        !statuses.contains(selectedStatus) ||
        !selectedUsers.isNotEmpty) {
      return false;
    }
    return true;
  }

  void _updateForm() async {
    for (int i = 0; i < activeUsers.length; i++) {
      if (userSelection[i]) {
        selectedUsers.add(activeUsersSnapshot.docs[i].id);
      }
    }
    if (_validateFields()) {
      try {
        CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Encuestas');
        collectionReference.doc(widget.id).update({
          'name': nameController.text,
          'startDate': startDateController.text,
          'endDate': endDateController.text,
          'days': daysController.text,
          'status': selectedStatus,
        }).then((mainDocRef) async {
          // Add subcollection 'Usuarios' and documents for each selected user
          for (String userId in selectedUsers) {
            var docSnapshot = await collectionReference.doc(widget.id).collection('Usuarios').doc(userId).get();
            if (!docSnapshot.exists) {
              await collectionReference.doc(widget.id).collection('Usuarios').doc(userId).set({
                  'status': 'ABIERTA',
              });
            }
          }
          // Get all documents in the collection
          var querySnapshot = await collectionReference.doc(widget.id).collection('Usuarios').get();
          // Iterate over each document in the collection
          for (var doc in querySnapshot.docs) {
            // Check if the document ID exists in selectedUsers
            if (!selectedUsers.contains(doc.id)) {
              // If not, delete the document
              await collectionReference.doc(widget.id).collection('Usuarios').doc(doc.id).delete();
            }
          }
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Encuesta guardada exitosamente.'),
            duration: Duration(seconds: 4),
          ),
        );

        nameController.clear();
        startDateController.clear();
        endDateController.clear();
        daysController.clear();

        widget.reloadList();

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } catch (e) {
        // Handle errors
        print('Error saving user: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el usuario. Por favor, inténtelo de nuevo más tarde.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      // Show error message if fields are incomplete or invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, complete todos los campos correctamente.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}

