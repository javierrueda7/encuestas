import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getParametro(String param) async {
  List<Map<String, dynamic>> parametroList = [];
  final CollectionReference parametros = db.collection(param);

  // Query all documents
  QuerySnapshot allParam = await parametros.get();
  for (var document in allParam.docs) {
    Map<String, dynamic> parametro = {
      'id': document.id,
      'data': document.data(),
    };
    parametroList.add(parametro);
  }

  // Custom sort function
  parametroList.sort((a, b) {
    String statusA = a['data']['status'];
    String statusB = b['data']['status'];

    // First sort by status
    int statusComparison = compareStatus(statusA, statusB);
    if (statusComparison != 0) {
      return statusComparison;
    }

    // Conditional sorting based on 'param'
    if (param == 'Actividades') {
      String idA = a['id'];
      String idB = b['id'];
      return idA.compareTo(idB);
    } else {
      String nameA = a['data']['name'];
      String nameB = b['data']['name'];
      return nameA.compareTo(nameB);
    }
  });

  return parametroList;
}

int compareStatus(String statusA, String statusB) {
  const statusOrder = ['PENDIENTE', 'ACTIVO', 'INACTIVO'];
  int indexA = statusOrder.indexOf(statusA);
  int indexB = statusOrder.indexOf(statusB);

  // Handle cases where status is not in the predefined list
  if (indexA == -1) indexA = statusOrder.length;
  if (indexB == -1) indexB = statusOrder.length;

  return indexA.compareTo(indexB);
}

Future<List> validLogin() async {
  List users = [];
  QuerySnapshot? queryUsers = await db.collection('Usuarios').get();
  for (var doc in queryUsers.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['status'] != 'INACTIVO') {
      final user = {
        "uid": doc.id,
        "name": data['name'],
        "email": data['email'],
        "status": data['status'],
        "role": data['role'],
      };
      users.add(user);
    }
  }
  return users;
}

Future<String> getFormState(String formId, String userId) async {  
  DocumentSnapshot formDoc = await FirebaseFirestore.instance.collection('Encuestas').doc(formId).collection('Usuarios').doc(userId).get();

  if (formDoc.exists) {
    return formDoc['status'];
  } else {
    throw Exception('Documento de encuesta no encontrado');
  }
}

Future<String> getUserRole() async {
  // Obtener el usuario autenticado
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Obtener el ID del usuario
    String userId = user.uid;

    // Buscar el documento en la colección "Usuarios"
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(userId).get();

    if (userDoc.exists) {
      // Retornar el campo 'rol'
      return userDoc['rol'];
    } else {
      throw Exception('Documento de usuario no encontrado');
    }
  } else {
    throw Exception('No hay un usuario autenticado');
  }
}

Future<List<Map<String, dynamic>>> getUsuarios() async {
  List<Map<String, dynamic>> usersList = [];
  final CollectionReference usuarios = db.collection('Usuarios');
  final CollectionReference positions = db.collection('Cargos');
  final CollectionReference professions = db.collection('Profesiones');

  // Fetch positions and professions to create a mapping of id to name
  Map<String, String> positionNames = {};
  Map<String, String> professionNames = {};

  QuerySnapshot positionDocs = await positions.get();
  for (var document in positionDocs.docs) {
    var data = document.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('name')) {
      positionNames[document.id] = data['name'] as String;
    }
  }

  QuerySnapshot professionDocs = await professions.get();
  for (var document in professionDocs.docs) {
    var data = document.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('name')) {
      professionNames[document.id] = data['name'] as String;
    }
  }

  // Query documents from 'Usuarios'
  QuerySnapshot users = await usuarios.get();
  for (var document in users.docs) {
    var data = document.data() as Map<String, dynamic>?;
    if (data != null) {
      String positionName = positionNames[data['position']] ?? 'Unknown Position';
      String professionName = professionNames[data['profession']] ?? 'Unknown Profession';

      Map<String, dynamic> usuario = {
        'id': document.id,
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'role': data['role'] ?? '',
        'status': data['status'] ?? '',
        'gender': data['gender'] ?? '',
        'idType': data['idType'] ?? '',
        'sede': data['sede'] ?? '',
        'positionId': data['position'] ?? '',
        'position': positionName,
        'professionId': data['profession'] ?? '',
        'profession': professionName,
      };
      usersList.add(usuario);
    }
  }

  // Sort the usersList by 'status' and then by 'name'
  usersList.sort((a, b) {
    // Compare 'status' first
    int statusComparison = a['status'] == 'ACTIVO' && b['status'] != 'ACTIVO'
        ? -1
        : (a['status'] != 'ACTIVO' && b['status'] == 'ACTIVO' ? 1 : 0);

    // If 'status' is the same, compare by 'name'
    if (statusComparison != 0) {
      return statusComparison;
    } else {
      return a['name'].compareTo(b['name']);
    }
  });

  return usersList;
}

Future<List<Map<String, dynamic>>> getEncuestas() async {
  List<Map<String, dynamic>> formsList = [];
  final CollectionReference forms = db.collection('Encuestas');

  // Apply a query filter to fetch documents where status != "ELIMINADA"
  QuerySnapshot form = await forms.where('status', isNotEqualTo: 'ELIMINADA').get();
  
  for (var document in form.docs) {
    // Fetch the Usuarios subcollection
    final CollectionReference usuariosSubcollection = forms.doc(document.id).collection('Usuarios');
    QuerySnapshot usuariosSnapshot = await usuariosSubcollection.get();

    // Calculate the total number of documents in Usuarios subcollection
    int totalUsuarios = usuariosSnapshot.size;

    // Calculate the number of documents with status != 'ENVIADA'
    int nonEnviadaCount = usuariosSnapshot.docs.where((doc) => doc['status'] != 'ENVIADA').length;

    Map<String, dynamic> encuesta = {
      'id': document.id,
      'data': document.data(),
      'usuariosTotal': totalUsuarios,
      'usuariosNonEnviada': nonEnviadaCount,
    };
    formsList.add(encuesta);
  }
  formsList.sort((a, b) => b['id'].compareTo(a['id']));
  return formsList;
}

Future<Map<String, dynamic>?> getEncuestaWithUsers(String encuestaId) async {
  // Reference to the specific "Encuesta" document
  final DocumentReference encuestaDocRef = db.collection('Encuestas').doc(encuestaId);

  // Get the "Encuesta" document
  DocumentSnapshot encuestaDoc = await encuestaDocRef.get();

  // Check if the "Encuesta" document exists and its status is not 'ELIMINADA' or 'CREADA'
  if (encuestaDoc.exists) {
    var encuestaData = encuestaDoc.data() as Map<String, dynamic>?;
    if (encuestaData != null && encuestaData['status'] != 'ELIMINADA' && encuestaData['status'] != 'CREADA') {
      // Reference to the "Usuarios" subcollection within the current "Encuesta" document
      final CollectionReference usuariosCollection = encuestaDocRef.collection('Usuarios');

      // Query the "Usuarios" subcollection
      QuerySnapshot usuariosSnapshot = await usuariosCollection.get();

      // Convert the documents to a list of maps
      List<Map<String, dynamic>> usuariosList = usuariosSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Sort the list of users alphabetically by the 'name' field
      usuariosList.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      // Create a map for the "Encuesta" document with the sorted users list
      Map<String, dynamic> encuesta = {
        'id': encuestaDoc.id,
        'data': encuestaData,
        'users': usuariosList,
      };

      return encuesta;
    }
  }

  // Return null if no matching document is found or the conditions are not met
  return null;
}

Future<List<Map<String, dynamic>>> getEncuestasUser(String searchString) async {
  List<Map<String, dynamic>> formsList = [];
  
  // Reference to the "Encuestas" collection
  final CollectionReference encuestasCollection = db.collection('Encuestas');
  
  // Query documents within the "Encuestas" collection
  QuerySnapshot encuestasSnapshot = await encuestasCollection.get();
  
  for (var encuestaDoc in encuestasSnapshot.docs) {
    // Get the data of the current "Encuesta" document and check if it's null
    var encuestaData = encuestaDoc.data() as Map<String, dynamic>?;
    if (encuestaData != null && encuestaData['status'] != 'ELIMINADA' && encuestaData['status'] != 'CREADA') {
      // Reference to the "Usuarios" subcollection within the current "Encuesta" document
      final CollectionReference usuariosCollection = encuestaDoc.reference.collection('Usuarios');
      
      // Check if the given string matches any document ID within the "Usuarios" subcollection
      DocumentSnapshot usuarioDoc = await usuariosCollection.doc(searchString).get();
      
      // If a document with the matching ID is found in the subcollection
      if (usuarioDoc.exists) {
        // Create a map for the "Encuesta" document
        Map<String, dynamic> encuesta = {
          'id': encuestaDoc.id,
          'data': encuestaData,
          'user': usuarioDoc.data() as Map<String, dynamic>?
        };
        
        // Add the map to the list
        formsList.add(encuesta);
      }
    }
  }
  
  // Sort the list by 'id' in descending order
  formsList.sort((a, b) => b['id'].compareTo(a['id']));

  return formsList;
}

Future<String> saveParameter(String param, String nombre, String estado) async {
  // Get a reference to the collection
  CollectionReference collectionReference = FirebaseFirestore.instance.collection(param);

  // Generate a unique ID
  String docId = await idGenerator(collectionReference, param);

  // Add the document with the generated ID
  await collectionReference.doc(docId).set({
    'name': nombre.toUpperCase(),
    'status': estado.toUpperCase(),
  });

  print('Parameter saved successfully');
  return docId; // Return the new document ID
}

void saveUser(String id, String idType, String name, String phone, String email, String position, String profession, String role, String status) async {
  // Get a reference to the collection
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('Usuarios');
      
  collectionReference.doc(id).set({
    'idType': idType,
    'name': name,
    'phone': phone,
    'email': email.toLowerCase(),
    'position': position,
    'profession': profession,
    'role': role,
    'status': status,
  }).then((_) {
    print('Parameter saved successfully');
  }).catchError((error) {
    print('Failed to save parameter: $error');
  });
}

Future<String> idGenerator(CollectionReference ref, String collection) async {

  int counter = 0;
  String inicio = '';
  QuerySnapshot snapshot = await ref.get();
  counter = snapshot.size + 1;
  if(collection == 'Proyectos'){
    inicio = 'PR';
  } else if (collection == 'Profesiones'){
    inicio = 'PF';
  } else if (collection == 'Cargos'){
    inicio = 'CG';
  } else if (collection == 'Actividades'){
    inicio = 'AC';
  } else {
    inicio = collection[0];
  }
  String idGenerated = inicio + counter.toString().padLeft(4, '0');
  return idGenerated;
}

void updateParameter(String id, String param, String nombre, String estado) {
  FirebaseFirestore.instance.collection(param).doc(id).update({
    'name': nombre.toUpperCase(),
    'status': estado.toUpperCase(),
  }).then((value) {
    print('Parameter saved successfully');
  }).catchError((error) {
    print('Failed to save parameter: $error');
  });
}

Future<List<String>> getParamAuto(String param) async {
  List<String> parametros = [];
  QuerySnapshot? queryParametros = await db.collection(param).where('status', isEqualTo: 'ACTIVO').get();
  for (var doc in queryParametros.docs) {
    parametros.add(doc['name']);
  }
  return parametros;
}

Future<String?> fetchParameter(String param, String id) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance.collection(param).doc(id).get();
    if (docSnapshot.exists) {
      return docSnapshot['name'];
    } else {
      print('$param document does not exist');
      return null;
    }
  } catch (e) {
    print('Error fetching $param document: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchUserData(String userId) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance.collection('Usuarios').doc(userId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    } else {
      print('User document does not exist');
      return null;
    }
  } catch (e) {
    print('Error fetching user document: $e');
    return null;
  }
}





