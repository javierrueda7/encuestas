import 'package:flutter/material.dart';
import 'package:forms_app/listforms.dart';
import 'package:forms_app/listparam.dart';
import 'package:forms_app/listusers.dart';
import 'package:forms_app/userforms.dart';
/*import 'package:forms_app/loaddata.dart';
import 'package:forms_app/services/firebase_services.dart';*/

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('CYMA - ENCUESTAS MOP')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*ElevatedButton(
              onPressed: () async {
                List<String> columnData = await getDataFromExcel('prof.xlsx', 'Hoja1', 0);
                print(columnData);
                for (var item in columnData) {
                  // Perform your operation here, for example, print the item
                  // ignore: await_only_futures
                  await saveParameter('Profesiones', item, 'ACTIVO');
                  // You can replace this with your actual operation
                }
              },
              child: Text('Cargar excel'),
            ),*/
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListUserForms()),
                );
              },
              child: Text('RESPONDER ENCUESTA'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListFormsScreen()), // Navigate to the NewUserPage
                );
              },
              child: Text('ADMINISTRAR ENCUESTAS'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListUsersScreen()), // Navigate to the NewUserPage
                );
              },
              child: Text('ADMINISTRAR USUARIOS'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListParameterScreen(param: 'Proyectos')),
                );
              },
              child: Text('ADMINISTRAR PROYECTOS'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListParameterScreen(param: 'Actividades')),
                );
              },
              child: Text('ADMINISTRAR ACTIVIDADES'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListParameterScreen(param: 'Cargos')),
                );
              },
              child: Text('ADMINISTRAR CARGOS'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListParameterScreen(param: 'Profesiones')),
                );
              },
              child: Text('ADMINISTRAR PROFESIONES'),
            ),
          ],
        ),
      ),
    );
  }
}
