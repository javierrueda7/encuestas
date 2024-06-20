
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:forms_app/accesstoken.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/addeditforms.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:url_launcher/url_launcher.dart';

class ListFormsScreen extends StatefulWidget {

  ListFormsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListFormsScreenState createState() => _ListFormsScreenState();
}

class _ListFormsScreenState extends State<ListFormsScreen> {

  void _reloadList() {
    setState(() {}); // Empty setState just to trigger rebuild
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('ADMINISTRACIÓN DE ENCUESTAS')),
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
                future: getEncuestas(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data?[index];
                        return ListTile(
                          leading: Text(
                            item?['id'] ?? '',
                            style: TextStyle(fontSize: 12),
                          ),
                          title: Text(item?['data']['name'] ?? ''),
                          subtitle: Text('${item?['data']['startDate']} - ${item?['data']['endDate']}'),
                          trailing: SizedBox(
                            width: 300, // Ajusta el ancho según sea necesario
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${item?['data']['status'] ?? ''}',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      'USUARIOS ASOCIADOS: ${item?['usuariosTotal'] ?? ''}',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      'USUARIOS POR RESPONDER: ${item?['usuariosNonEnviada'] ?? ''}',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8), // Espacio entre la columna y los iconos
                                IconButton(
                                  onPressed: () {
                                    _loadAndShowUsers(context, item?['id']);
                                  },
                                  icon: Icon(Icons.remove_red_eye_outlined, color: Colors.blue),
                                ),                                
                                Visibility(
                                  visible: false,
                                  child: IconButton(
                                    onPressed: () {
                                      if (item != null && item.containsKey('id') && item['data']['status'] == 'ACTIVA') {
                                        confirmacionEmail(context, item['id'], item['data']['name']);
                                      }
                                    },
                                    icon: Icon(Icons.email_outlined, color: item?['data']['status'] == 'ACTIVA' ?  Colors.green : Colors.grey),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Asegúrate de que item contenga el campo 'id'
                                    if (item != null && item.containsKey('id') && item['data']['status'] == 'CREADA') {
                                      mostrarDialogoConfirmacion(context, item['id']);
                                    } else {
                                      print('Error: ID del documento no disponible');
                                    }
                                  },
                                  icon: Icon(Icons.delete_outline_outlined, color: item?['data']['status'] == 'CREADA' ?  Colors.red : Colors.grey),

                                ),
                              ],
                            ),
                          ),

                          onTap: () {
                            // Open edit dialog or perform edit action here
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddEditForm(
                                  reloadList: _reloadList,
                                  id: item?['id'], // Accessing the document ID
                                  name: item?['data']['name'],
                                  startDate: item?['data']['startDate'],
                                  endDate: item?['data']['endDate'],
                                  days: item?['data']['days'],
                                  status: item?['data']['status']
                                );
                              },
                            );
                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditForm(reloadList: _reloadList,)), // Navigate to the NewUserPage
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void mostrarDialogoConfirmacion(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CONFIRMACIÓN'),
          content: Text('¿ESTÁS SEGURO DE QUE DESEAS ELIMINAR ESTA ENCUESTA?'),
          actions: <Widget>[
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ELIMINAR'),
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo
                await eliminarItem(documentId); // Llama a la función de eliminación
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarItem(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('Encuestas').doc(documentId).update({
        'status': 'ELIMINADA'
      });
      print('Estado del documento actualizado a ELIMINADA con éxito');
      
      if (mounted) { // Verifica si el widget aún está montado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ENCUESTA ELIMINADA SATISFACTORIAMENTE')),
        );
        _reloadList(); // Asegúrate de definir _reloadList en tu widget para actualizar la lista
      }
    } catch (e) {
      print('Error al actualizar el estado del documento: $e');
      if (mounted) { // Verifica si el widget aún está montado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el documento: $e')),
        );
      }
    }
  }

  Future<void> sendEmail(String accessToken, String toEmail, String subject, String content) async {
    final url = Uri.parse('https://mail.zoho.com/api/accounts/$accountId/messages');
    final headers = {
      'Authorization': 'Zoho-oauthtoken $accessToken',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      'fromAddress': 'javieruedase@zohomail.com', // Reemplaza con tu dirección de correo electrónico
      'toAddress': toEmail,
      'subject': subject,
      'content': content
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('¡Correo electrónico enviado correctamente!');
    } else {
      print('Error al enviar el correo electrónico: ${response.body}');
    }
  }



  // Future<void> sendEmail(String id, String nameEncuesta) async {
  //   // Obtener los IDs de los usuarios seleccionados de la subcolección 'Usuarios' dentro de 'Encuestas'
  //   var selectedUsersSnapshot = await FirebaseFirestore.instance
  //       .collection('Encuestas')
  //       .doc(id)
  //       .collection('Usuarios')
  //       .get();

  //   var selectedUsersIds = selectedUsersSnapshot.docs.map((doc) => doc.id).toList();

  //   List<String> selectedEmails = [];

  //   // Obtener los correos electrónicos de la colección principal 'Usuarios'
  //   for (var userId in selectedUsersIds) {
  //     var userDoc = await FirebaseFirestore.instance
  //         .collection('Usuarios')
  //         .doc(userId)
  //         .get();
          
  //     var userData = userDoc.data();
  //     if (userDoc.exists && userData != null && userData.containsKey('email')) {
  //       selectedEmails.add(userData['email']);
  //     }
  //   }

  //   setState(() {
  //     // Aquí puedes actualizar el estado del widget si es necesario
  //   });

  //   // selectedEmails ahora contiene todos los emails de los usuarios seleccionados.
  //   print(selectedEmails);  // Para verificar la lista de correos electrónicos.
  //   manualSendEmail(selectedEmails, nameEncuesta);
  // }

  // Future<void> manualSendEmail(List<String> recipients, String nameEncuesta) async {
  //   String subject = "Invitación a resolver la encuesta $nameEncuesta";
  //   final String recipientsString = recipients.join(',');
  //   const String body = '''
  //     Hola, el área técnica de CyMA te invita a responder la última encuesta, copia y pega el siguiente link en tu navegador para visitar la plataforma de Encuestas MOP.

  //     https://javierrueda7.github.io/CYMA-EncuestasMOP/

  //     Si ya fue respondida, hacer caso omiso a este correo.

  //     Cordial saludo,

  //     Equipo CyMA - Encuestas MOP          
  //   ''';

  //   final String encodedSubject = Uri.encodeComponent(subject);
  //   final String encodedBody = Uri.encodeComponent(body);

  //   final Uri emailLaunchUri = Uri(
  //     scheme: 'mailto',
  //     path: recipientsString,
  //     query: 'subject=$encodedSubject&body=$encodedBody',
  //   );

  //   print('Email URI: ${emailLaunchUri.toString()}');

  //   try {
  //     if (await canLaunchUrl(emailLaunchUri)) {
  //       print('Launching email app...');
  //       await launchUrl(emailLaunchUri);
  //     } else {
  //       print('Could not launch $emailLaunchUri');
  //       throw 'Could not launch $emailLaunchUri';
  //     }
  //   } catch (e) {
  //     print('Error launching email app: $e');
  //   }
  // }



  void confirmacionEmail(BuildContext context, String id, String nameEncuesta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CONFIRMACIÓN'),
          content: Text('¿ESTÁS SEGURO QUE DESEAS ENVIAR LA INVITACIÓN A RESPONDER $nameEncuesta?'),
          actions: <Widget>[
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ENVIAR INVITACIONES'),
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo
                //await sendEmail(id, nameEncuesta); // Llama a la función de eliminación
                try {
                  final accessToken = await getAccessToken();
                  await sendEmail(
                    accessToken,
                    'javieruedase@gmail.com',
                    'Test Subject',
                    'Hello, this is a test email from Flutter!',
                  );
                } catch (e) {
                  print('Error: $e');
                }

              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadAndShowUsers(BuildContext context, String id) async {
    // Mostrar un círculo de carga mientras se obtienen los datos
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo haciendo clic fuera de él
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Obtener los documentos de la subcolección 'Usuarios' dentro de 'Encuestas'
      var selectedUsersSnapshot = await FirebaseFirestore.instance
          .collection('Encuestas')
          .doc(id)
          .collection('Usuarios')
          .get();

      // Filtrar los IDs basados en status != 'ENVIADA'
      var selectedUsersIds = selectedUsersSnapshot.docs
          .where((doc) => doc.data()['status'] != 'ENVIADA')
          .map((doc) => doc.id)
          .toList();

      List<String> userNames = [];

      // Obtener los nombres de la colección principal 'Usuarios' usando los IDs filtrados
      for (var userId in selectedUsersIds) {
        var userDoc = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .get();

        var userData = userDoc.data();
        if (userDoc.exists && userData != null && userData.containsKey('name')) {
          userNames.add(userData['name']);
        }
      }

      // Cerrar el círculo de carga
      Navigator.of(context).pop();

      // Mostrar el diálogo con la lista de nombres
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            alignment: Alignment.center,
            actionsAlignment: MainAxisAlignment.center,
            title: Text('USUARIOS POR RESPONDER'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: userNames.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(userNames[index]),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CERRAR'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

    } catch (e) {
      // Manejar errores aquí si es necesario
      print('Error: $e');
      // Cerrar el círculo de carga en caso de error
      Navigator.of(context).pop();
    }
  }

}
