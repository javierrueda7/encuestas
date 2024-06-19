// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class FormsPage extends StatefulWidget {
  final String idForm; // Nullable to differentiate between adding and editing
  final String formName;
  final String dates;
  final String uidUser;
  final String hours;
  final VoidCallback reloadList;
  FormsPage({super.key, required this.idForm, required this.formName, required this.dates, required this.uidUser, required this.hours, required this.reloadList,});
  
  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  // Controllers
  final TextEditingController idTypeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController sedeController = TextEditingController();
  
  // Projects and activities
  List<Map<String, dynamic>> projects = [];
  List<Parametro> projectsList = [];
  List<Parametro> activitiesList = [];
  String expectedHours = '';
  int totalHours = 0;

  List<TextEditingController> projectControllers = [];
  List<TextEditingController> activityControllers = [];
  List<TextEditingController> hoursControllers = [];

  // Initialize controllers and data in initState
  @override
  void initState() {
    super.initState();
    retrieveData();
    initPro();
    initAct();
    for (var project in projects) {
      projectControllers.add(TextEditingController(text: project['projectName']));
      activityControllers.add(TextEditingController(text: project['activityName']));
      hoursControllers.add(TextEditingController(text: project['hours']?.toString()));
    }
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    idTypeController.dispose();
    nameController.dispose();
    idController.dispose();
    roleController.dispose();
    positionController.dispose();
    professionController.dispose();
    sedeController.dispose();
    // Dispose all controllers
    for (var controller in projectControllers) {
      controller.dispose();
    }
    for (var controller in activityControllers) {
      controller.dispose();
    }
    for (var controller in hoursControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> initPro() async {
    projectsList = await getParamwithId('Proyectos');
    projectsList.sort((a, b) => a.name.trim().compareTo(b.name.trim()));
  }

  Future<void> initAct() async {
    activitiesList = await getParamwithId('Actividades');
  }

  Future<List<Parametro>> getSugProjects(String query) async {
    List<Parametro> savedProjects = await getParamwithId('Proyectos');
    List<Parametro> filteredProjects = savedProjects
        .where((project) => project.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    filteredProjects.sort((a, b) => a.name.trim().compareTo(b.name.trim()));
    return filteredProjects;
  }

  Future<List<Parametro>> getSugActivities(String query) async {
    List<Parametro> savedActivities = await getParamwithId('Actividades');
    List<Parametro> filteredActivities = savedActivities
        .where((activity) => activity.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredActivities;
  }

  Future<List<Parametro>> getParamwithId(String param) async {
    List<Parametro> parametros = [];
    QuerySnapshot queryParametros = await FirebaseFirestore.instance.collection(param).where('status', isEqualTo: 'ACTIVO').get();
    for (var doc in queryParametros.docs) {
      parametros.add(Parametro(id: doc.id, name: doc['name']));
    }
    return parametros;
  }
  
  Future<void> retrieveData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.uidUser)
          .get();

      if (snapshot.exists) {
        // Access data from snapshot
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          final profession = await fetchParameter('Profesiones', data['profession']);
          final position = await fetchParameter('Cargos', data['position']);
          setState(() {
            idTypeController.text = data['idType'] ?? '';
            idController.text = data['id'] ?? '';
            nameController.text = data['name'] ?? '';
            roleController.text = data['role'] ?? '';
            professionController.text = profession ?? '';
            positionController.text = position ?? '';
            sedeController.text = data['sede'] ?? '';
            expectedHours = widget.hours;
          });
        }
      }
    } catch (error) {
      print("Error retrieving data: $error");
    }
  }

  void addProject() {
    setState(() {
      final newProject = {
        'projectName': '',
        'activityName': '',
        'hours': '0'
      };
      projects.add(newProject);

      final projectController = TextEditingController();
      final activityController = TextEditingController();
      final hoursController = TextEditingController();

      projectControllers.add(projectController);
      activityControllers.add(activityController);
      hoursControllers.add(hoursController);

      // Add listeners to update the projects list
      projectController.addListener(() {
        newProject['projectName'] = projectController.text;
      });

      activityController.addListener(() {
        newProject['activityName'] = activityController.text;
      });

      hoursController.addListener(() {
        newProject['hours'] = hoursController.text;
        updateTotalHours();
      });
    });
  }


  void removeProject(int index) {
    setState(() {
      projects.removeAt(index);
      projectControllers[index].dispose();
      activityControllers[index].dispose();
      hoursControllers[index].dispose();
      projectControllers.removeAt(index);
      activityControllers.removeAt(index);
      hoursControllers.removeAt(index);
      updateTotalHours();
    });
  }

  void updateTotalHours() {
    int newTotal = 0;
    for (var project in projects) {
      var temp = project['hours'];
      if (temp != null && temp.toString().isNotEmpty) {
        newTotal += int.parse(temp.toString());
      }
    }
    setState(() {
      totalHours = newTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('${widget.formName.toUpperCase()} - ${widget.dates}')),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(350, 50, 350, 50),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: buildTextField('TIPO DE DOCUMENTO', idTypeController, true)),            
                    SizedBox(width: 10),
                    Expanded(child: buildTextField('NÚMERO DE IDENTIFICACIÓN', idController, true)),
                    SizedBox(width: 10),
                    Expanded(child: buildTextField('SEDE', sedeController, true)),
                  ],
                ),
                SizedBox(height: 10),
                buildTextField('NOMBRE', nameController, true),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: buildTextField('ROL', roleController, true)),
                    SizedBox(width: 10),            
                    Expanded(child: buildTextField('CARGO', positionController, true)),
                    SizedBox(width: 10),            
                    Expanded(child: buildTextField('PROFESIÓN', professionController, true)),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LISTA DE ACTIVIDADES',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'HORAS ESPERADAS: $expectedHours',
                          style: TextStyle(fontSize: 14,),
                        ),
                        Text(
                          'HORAS REGISTRADAS: $totalHours',
                          style: TextStyle(fontSize: 14,),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return buildProjectItem(index);
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addProject,
                  child: Text('AGREGAR ACTIVIDAD'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool toReview = false;
                    // First, update the projects list with the latest controller values
                    setState(() {
                      for (int i = 0; i < projects.length; i++) {
                        projects[i]['projectName'] = projectControllers[i].text;
                        projects[i]['activityName'] = activityControllers[i].text;
                        projects[i]['hours'] = hoursControllers[i].text;
                      }
                    });
            
                    // Then, handle new projects and activities
                    for (var project in projects) {
                      if (!projectsList.any((p) => p.name == project['projectName'])) {
                        // String newProjectId = await saveParameter('Proyectos', project['projectName'], 'PENDIENTE');
                        // project['project'] = newProjectId;
                        toReview = true;
                      } else {
                        project['project'] = projectsList.firstWhere((p) => p.name == project['projectName']).id;
                      }
            
                      if (!activitiesList.any((a) => a.name == project['activityName'])) {
                        // String newActivityId = await saveParameter('Actividades', project['activityName'], 'PENDIENTE');
                        // project['activity'] = newActivityId;
                        toReview = true;
                      } else {
                        project['activity'] = activitiesList.firstWhere((a) => a.name == project['activityName']).id;
                      }
                    }
            
                    // Print all elements of the projects list with updated IDs
                    for (var project in projects) {
                      print("?idencuesta=${widget.idForm}&idusuario=${widget.uidUser}&proyecto=${project['project']}&actividad=${project['activity']}&horas=${project['hours']}&fecha=${DateTime.now()}");
                    }
                    
                    if(toReview){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Seleccione únicamente Actividades o Proyectos existentes.'),
                          duration: Duration(seconds: 4),
                        ),
                      );
                      return;                      
                    } else {
                      List<String> projectStrings = [];

                      for (var project in projects) {
                        projectStrings.add("?idencuesta=${widget.idForm}&idusuario=${widget.uidUser}&proyecto=${project['project']}&actividad=${project['activity']}&horas=${project['hours']}&fecha=${DateTime.now()}");
                      }

                      String resultString = projectStrings.join(';');                      
                      print(resultString);
                      _submitForm();
                      FirebaseFirestore.instance.collection('Encuestas').doc(widget.idForm).collection('Usuarios').doc(widget.uidUser).update({
                        'answer': resultString,
                        'status': 'ENVIADA',
                        'date': DateTime.now(),
                        'idencuesta': widget.idForm
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Encuesta respondida exitosamente.'),
                          duration: Duration(seconds: 4),
                        ),
                      );
                      widget.reloadList();
                      Navigator.of(context).pop();
                    }
            
                    // Implement additional submit functionality here (e.g., saving to Firestore)
                  },
                  child: Text('ENVIAR'),
                ),
            
              ],
            ),
          ),
        ),
      ),
    );
  }
  late final _formKey;
  void _submitForm() async {
    const String scriptURL = 'https://script.google.com/macros/s/AKfycbwl1b-qt61HCxZG2QtLYNsqvmAgVQ6NRUmEGbV0SQQaL4Hl6Yh3pwF2WpNkk-EJrAlq/exec';

    for (var project in projects) {
      String queryString = "?idencuesta=${widget.idForm}&idusuario=${widget.uidUser}&proyecto=${project['project']}&actividad=${project['activity']}&horas=${project['hours']}&fecha=${DateTime.now()}";

      var finalURI = Uri.parse(scriptURL + queryString);
      var response = await http.get(finalURI);
      //print(finalURI);

      if (response.statusCode == 200) {
        var bodyR = convert.jsonDecode(response.body);
        print(bodyR);
      }
    }
  }


  Widget buildProjectItem(int index) {
    TextEditingController projectController = projectControllers[index];
    TextEditingController activityController = activityControllers[index];
    TextEditingController hoursController = hoursControllers[index];

    projectController.addListener(() {
      final text = projectController.text.toUpperCase();
      if (projectController.text != text) {
        projectController.value = projectController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });

    activityController.addListener(() {
      final text = activityController.text.toUpperCase();
      if (activityController.text != text) {
        activityController.value = activityController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TypeAheadFormField<Parametro>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: projectController,
                decoration: InputDecoration(
                  labelText: 'PROYECTO',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              suggestionsCallback: getSugProjects,
              onSuggestionSelected: (project) {
                setState(() {
                  projects[index]['project'] = project.id;
                  projects[index]['projectName'] = project.name;
                  projectController.text = project.name;
                });
              },
              autovalidateMode: AutovalidateMode.always,
              validator: (proyecto) {
                if (proyecto!.isEmpty) {
                  return 'SELECCIONE UN PROYECTO DE LA LISTA';
                } else if (!projectsList.any((project) => project.name == proyecto)) {
                  return 'PENDIENTE DE REVISIÓN POR UN ADMINISTRADOR';
                } else {
                  return null;
                }
              },
              itemBuilder: (context, project) {
                return ListTile(
                  title: Text(project.name),
                );
              },
              onSaved: (proyecto) async {
                if (proyecto != null && !projectsList.any((project) => project.name == proyecto)) {
                  await saveParameter('Proyectos', proyecto, 'PENDIENTE');
                  projectsList.add(Parametro(id: DateTime.now().toString(), name: proyecto)); // Temporarily add the new project
                }
              },
              noItemsFoundBuilder: (context) {
                return const SizedBox.shrink();
              },
            ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TypeAheadFormField<Parametro>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: activityController,
                  decoration: InputDecoration(
                    labelText: 'ACTIVIDAD',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),
                suggestionsCallback: getSugActivities,
                onSuggestionSelected: (activity) {
                  setState(() {
                    projects[index]['activity'] = activity.id;
                    projects[index]['activityName'] = activity.name;
                    activityController.text = activity.name;
                  });
                },
                autovalidateMode: AutovalidateMode.always,
                validator: (activity) {
                  if (activity!.isEmpty) {
                    return 'SELECCIONE UNA ACTIVIDAD DE LA LISTA';
                  } else if (!activitiesList.any((act) => act.name == activity)) {
                    return 'PENDIENTE DE REVISIÓN POR UN ADMINISTRADOR';
                  } else {
                    return null;
                  }
                },
                itemBuilder: (context, activity) {
                  return ListTile(
                    title: Text(activity.name),
                  );
                },
                onSaved: (activity) async {
                  // Save the ocupacion to Firebase if it's a new value
                  if (!activitiesList.any((act) => act.name == activity)) {
                    saveParameter('Actividades', activity!, 'PENDIENTE');
                  }
                },
                noItemsFoundBuilder: (context) {
                  return const SizedBox.shrink();
                },
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 200,
              child: TextFormField(
                controller: hoursController,
                readOnly: false,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: 'HORAS DEDICADAS',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                onChanged: (value) {
                  int? newValue = int.tryParse(value);
                  setState(() {
                    projects[index]['hours'] = newValue?.toString(); // Store as String to avoid type issues
                    updateTotalHours();
                  });
                  // Preserve cursor position
                  hoursController.value = hoursController.value.copyWith(
                    text: value,
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            IconButton(
              onPressed: () {
                removeProject(index);
              },
              icon: Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller, bool readOnly) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}

class Parametro {
  final String id;
  final String name;

  Parametro({required this.id, required this.name});
}
