import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

Future<List<String>> getDataFromExcel(String filePath, String sheetName, int columnIndex) async {
  ByteData data = await rootBundle.load(filePath);
  var bytes = data.buffer.asUint8List();
  var excel = Excel.decodeBytes(bytes);

  // Retrieve the specified sheet
  var table = excel[sheetName];

  List<String> columnData = [];
  
  // Start iterating from the second row
  for (var i = 0; i < table.rows.length; i++) {
    var tableRow = table.rows[i];
    var cellValue = tableRow[columnIndex]?.value;
    if (cellValue != null) {
      columnData.add(cellValue.toString());
    }
  }

  return columnData;
}


