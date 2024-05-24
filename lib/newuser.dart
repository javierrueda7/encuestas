
// ignore: must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:forms_app/widgets/forms_widgets.dart';
import 'package:random_string/random_string.dart';
import 'dart:async';

class AddEditUser extends StatefulWidget {
  final String? id; // Nullable to differentiate between adding and editing
  final String? role;
  final String? status;
  final String? typeId;
  final String? gender;
  final String? sede;
  final bool? admin;
  
  final VoidCallback reloadList;

  AddEditUser({this.id, this.typeId, this.gender, this.role, this.status, this.sede, required this.reloadList, required this.admin});

  @override
  // ignore: library_private_types_in_public_api
  _AddEditUserState createState() => _AddEditUserState();
}

class _AddEditUserState extends State<AddEditUser> {
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController bdayController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController professionController;
  late TextEditingController positionController;
  TextEditingController passwordController = TextEditingController();

  late String selectedIdType;
  late String selectedGender;
  late String selectedRole;
  late String selectedStatus;
  late String selectedSede;
  late String userId;
  late bool admin;

  final List<dynamic> idTypes = ['CÉDULA DE CIUDADANÍA', 'CÉDULA DE EXTRANJERÍA', 'PASAPORTE', 'NIT', 'OTRO'];
  final List<dynamic> genders = ['MASCULINO', 'FEMENINO', 'OTRO'];
  final List<dynamic> roles = ['USUARIO', 'CONSULTOR', 'ADMINISTRADOR'];
  final List<dynamic> sedes = ['BUCARAMANGA', 'BOGOTÁ'];
  List<dynamic> positionsList = [];
  List<dynamic> professionsList = [];
  String? selectedPositionId;
  String? selectedProfessionId;
  final List<dynamic> statuses = ['ACTIVO', 'INACTIVO'];

  Future<void> initPos() async {
    positionsList = await getParamwithId('Cargos');
  }

  Future<void> initProf() async {
    professionsList = await getParamwithId('Profesiones');
  }

  Future<List<Parametro>> getSugPositions(String query) async {
    List<Parametro> savedCargos = await getParamwithId('Cargos');
    List<Parametro> filteredCargos = savedCargos
        .where((cargo) => cargo.name.contains(query))
        .toList();
    return filteredCargos;
  }

  Future<List<Parametro>> getParamwithId(String param) async {
    List<Parametro> parametros = [];
    QuerySnapshot queryParametros = await FirebaseFirestore.instance.collection(param).where('status', isEqualTo: 'ACTIVO').get();
    for (var doc in queryParametros.docs) {
      parametros.add(Parametro(id: doc.id, name: doc['name']));
    }
    return parametros;
  }
  
  Future<List<Parametro>> getSugProfessions(String query) async {
    List<Parametro> savedProfesiones = await getParamwithId('Profesiones');
    List<Parametro> filteredProfesiones = savedProfesiones
        .where((profesion) => profesion.name.contains(query))
        .toList();
    return filteredProfesiones;
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize state variables with defaults or widget parameters
    userId = widget.id ?? '';
    selectedIdType = widget.typeId ?? 'TIPO DE DOCUMENTO';
    selectedGender = widget.gender ?? 'GÉNERO';
    selectedStatus = widget.status ?? 'ACTIVO';
    selectedRole = widget.role ?? 'USUARIO';
    selectedSede = widget.sede ?? 'SEDE';
    admin = widget.admin ?? false;

    
    // Initialize controllers
    idController = TextEditingController();
    nameController = TextEditingController();
    bdayController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    professionController = TextEditingController();
    positionController = TextEditingController();
    
    // Initialize professional and positional data
    initProf();
    initPos();

    // Fetch user data if widget.id is not null
    if (widget.id != null) {
      fetchAndPopulateUserData(widget.id!);
    }
  }

  // Method to fetch user data and populate controllers
  void fetchAndPopulateUserData(String userId) async {
    try {
      final userData = await fetchUserData(userId);
      if (userData != null) {
        // Fetch additional parameters asynchronously
        final profession = await fetchParameter('Profesiones', userData['profession']);
        final position = await fetchParameter('Cargos', userData['position']);

        // Update state with fetched data
        setState(() {
          idController.text = userData['id'] ?? '';
          nameController.text = userData['name'] ?? '';
          bdayController.text = userData['bday'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          emailController.text = userData['email'] ?? '';
          professionController.text = profession ?? '';
          positionController.text = position ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }  

  @override
  Widget build(BuildContext context) {
    professionController.addListener(() {
      final text = professionController.text.toUpperCase();
      if (professionController.text != text) {
        professionController.value = professionController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
    positionController.addListener(() {
      final text = positionController.text.toUpperCase();
      if (positionController.text != text) {
        positionController.value = positionController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
    initPos();
    initProf();
    print(professionsList);
    print(positionsList);
    return AlertDialog(
      title: Center(child: Text(widget.id != null ? 'EDITAR USUARIO' : 'CREAR USUARIO')),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: buildDropdownField('TIPO DE DOCUMENTO', idTypes, (value) {
                    setState(() {
                      selectedIdType = value ?? 'TIPO DE DOCUMENTO'; // Ensure a default value if null
                    });
                  }, initialValue: selectedIdType),
                ),
                SizedBox(width: 10),
                Expanded(child: buildTextField('NÚMERO DE IDENTIFICACIÓN', idController, false)),
                SizedBox(width: 10),
                Expanded(
                  child: buildDropdownField('SEDE', sedes, (value) {
                    setState(() {
                      selectedSede = value ?? 'SEDE'; // Ensure a default value if null
                    });
                  }, initialValue: selectedSede),
                ),
              ],
            ),
            SizedBox(height: 10),
            buildTextField('NOMBRE', nameController, false),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: buildDateField('FECHA DE NACIMIENTO', bdayController, context)),
                SizedBox(width: 10),
                Expanded(
                  child: buildDropdownField(
                    'GÉNERO', genders, (value) {
                      setState(() {
                        selectedGender = value ?? 'GÉNERO';
                      });
                    }, initialValue: selectedGender
                  ),
                ),
                Visibility(
                  visible: !admin,
                  child: SizedBox(width: 10),
                ),
                Visibility(
                  visible: !admin,
                  child: Expanded(child: PasswordField(
                    label: 'CONTRASEÑA',
                    controller: passwordController,
                  ),)
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: buildNumberField('CELULAR', phoneController, false)),
                SizedBox(width: 10),
                Expanded(child: buildTextField('EMAIL', emailController, widget.id != null ? true : false)),
              ],
            ),
            SizedBox(height: 10),
            Container(
              constraints: BoxConstraints(maxWidth: 800),                    
              child: Row(
                children: [
                  Expanded(
                    child: TypeAheadFormField<Parametro>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: positionController,
                        decoration: InputDecoration(
                          hintText: 'CARGO',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                      suggestionsCallback: getSugPositions,
                      itemBuilder: (context, cargo) {
                        return ListTile(
                          title: Text(cargo.name),
                        );
                      },
                      onSuggestionSelected: (cargo) {
                        setState(() {
                          positionController.text = cargo.name;
                          selectedPositionId = cargo.id;
                          print(selectedPositionId);
                        });
                      },
                      autovalidateMode: AutovalidateMode.always,
                      validator: (position) {
                        if (position!.isEmpty || !positionsList.any((cargo) => cargo.name == position)) {
                          return 'SELECCIONE UN CARGO DE LA LISTA';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (position) {
                        setState(() {
                          // Handle saving the selected cargo id if needed
                        });
                      },
                    ),
                  ),                  
                  SizedBox(width: 10),                  
                  Expanded(
                    child: TypeAheadFormField<Parametro>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: professionController,
                        decoration: InputDecoration(                          
                          hintText: 'PROFESIÓN',                          
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),                        
                        ),
                      ),
                      suggestionsCallback: getSugProfessions,
                      itemBuilder: (context, profesion) {
                        return ListTile(
                          title: Text(profesion.name),
                        );
                      },
                      onSuggestionSelected: (profesion) {
                        setState(() {
                          professionController.text = profesion.name;
                          selectedProfessionId = profesion.id;
                        });
                      },                   
                      autovalidateMode: AutovalidateMode.always,
                      validator: (profession) {
                        if (profession!.isEmpty || !professionsList.any((profesion) => profesion.name == profession)) {
                          return 'SELECCIONE UNA PROFESIÓN DE LA LISTA';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (profession) {
                        // Save the ocupacion to Firebase if it's a new value
                        setState(() {
                          
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Visibility(
              visible: admin,
              child: Row(
                children: [
                  Expanded(
                    child: buildDropdownField(
                      'ROL', roles, (value) {
                        setState(() {
                          selectedRole = value ?? 'ROL';
                        });
                      }, initialValue: selectedRole
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: buildDropdownField(
                      'ESTADO', statuses, (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      }, initialValue: selectedStatus
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButton('GUARDAR', Colors.green, () {
                  if (widget.id != null) {
                    _updateUser(userId);
                  } else {
                    _saveUser();
                  }
                }),
                buildButton('CANCELAR', Colors.red, () => Navigator.pop(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }  

  void _saveUser() async {
    // Validate fields
    if (_validateFields()) {
      try {
        // Step 1: Check if email is already in use
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Usuarios')
            .where('email', isEqualTo: emailController.text.toUpperCase())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Email already in use
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('El correo electrónico ya está en uso.'),
              duration: Duration(seconds: 4),
            ),
          );
          return; // Exit the function if email is in use
        }

        // Step 2: Create user in Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: widget.admin == true ? randomAlphaNumeric(10) : passwordController.text,
        );

        // Step 3: Save user data to Firestore
        await FirebaseFirestore.instance.collection('Usuarios').doc(userCredential.user!.uid).set({
          'idType': selectedIdType.toUpperCase(),
          'id': idController.text.toUpperCase(),
          'name': nameController.text.toUpperCase(),
          'bday': bdayController.text.toUpperCase(),
          'gender': selectedGender.toUpperCase(),
          'phone': phoneController.text.toUpperCase(),
          'email': emailController.text.toUpperCase(),
          'position': selectedPositionId?.toUpperCase(),
          'profession': selectedProfessionId?.toUpperCase(),
          'role': selectedRole.toUpperCase(),
          'status': selectedStatus.toUpperCase(),
          'sede': selectedSede.toUpperCase(),
        });

        // Step 4: Send email verification
        await userCredential.user!.sendEmailVerification();

        // Step 5: Add user to "Usuarios" subcollection in "Encuestas" with "ACTIVA" status
        QuerySnapshot encuestasSnapshot = await FirebaseFirestore.instance
            .collection('Encuestas')
            .where('status', isEqualTo: 'ACTIVA')
            .get();

        for (var encuestaDoc in encuestasSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('Encuestas')
              .doc(encuestaDoc.id)
              .collection('Usuarios')
              .doc(userCredential.user!.uid)
              .set({
            'status': 'ABIERTA',
          });
        }

        // Show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario guardado exitosamente. Se ha enviado un correo electrónico para verificar la cuenta.'),
            duration: Duration(seconds: 4),
          ),
        );

        // Clear fields after saving
        idController.clear();
        nameController.clear();
        bdayController.clear();
        phoneController.clear();
        emailController.clear();

        // Trigger reload of user list
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
    print(idController.text);
    print(nameController.text);
    print(bdayController.text);
    print(phoneController.text);
    print(emailController.text);
    print(positionsList);
    print(selectedPositionId);
    print(professionsList);
    print(selectedProfessionId);

    bool isPositionValid = positionsList.any((position) => position.id == selectedPositionId);
    bool isProfessionValid = professionsList.any((profession) => profession.id == selectedProfessionId);

    // Perform other validations
    if (idController.text.isEmpty ||
        nameController.text.isEmpty ||
        bdayController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        !genders.contains(selectedGender) ||
        !idTypes.contains(selectedIdType) ||
        !statuses.contains(selectedStatus) ||
        !roles.contains(selectedRole) ||
        !sedes.contains(selectedSede) ||
        !isPositionValid ||
        !isProfessionValid) {
      return false;
    }

    // Validate password only when admin is false
    if (widget.admin != true && passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingrese una contraseña.'),
          duration: Duration(seconds: 4),
        ),
      );
      return false;
    }

    // All validations passed
    return true;
  }



  Future<void> _updateUser(String? uid) async {
  // Validate fields
  print(uid);
  print(selectedIdType);
  print(selectedGender);
  print(idController.text);
  print(nameController.text);
  print(bdayController.text);
  print(selectedGender);
  print(phoneController.text);
  print(emailController.text);
  print(selectedPositionId);
  print(selectedProfessionId);
  print(selectedRole);
  print(selectedStatus);
  if (_validateFields()) {
    try {
      // Step 1: Update user data in Firestore
      await FirebaseFirestore.instance.collection('Usuarios').doc(uid).update({
        'idType': selectedIdType.toUpperCase(),
        'id': idController.text.toUpperCase(),
        'name': nameController.text.toUpperCase(),
        'bday': bdayController.text.toUpperCase(),
        'gender': selectedGender.toUpperCase(),
        'phone': phoneController.text.toUpperCase(),
        'email': emailController.text.toUpperCase(),
        'position': selectedPositionId?.toUpperCase(),
        'profession': selectedProfessionId?.toUpperCase(),
        'role': selectedRole.toUpperCase(),
        'status': selectedStatus.toUpperCase(),
        'sede': selectedSede.toUpperCase()
      });      

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Información de usuario actualizada correctamente.'),
          duration: Duration(seconds: 4),
        ),
      );

      // Clear fields after saving
      idController.clear();
      nameController.clear();
      bdayController.clear();
      phoneController.clear();
      emailController.clear();

      // Trigger reload of user list
      widget.reloadList();

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (e) {
      // Handle errors
      print('Error updating user: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la información del usuario. Por favor, inténtelo de nuevo más tarde.'),
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

class Parametro {
  final String id;
  final String name;

  Parametro({required this.id, required this.name});
}


