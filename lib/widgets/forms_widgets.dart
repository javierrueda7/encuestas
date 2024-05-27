import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final RegExp regExp = RegExp(r'^\+?[0-9]*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}

Widget buildDateField(String label, TextEditingController controller, BuildContext context) {
  return TextFormField(
    controller: controller,
    onTap: () async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050),
      );
      if (picked != null && picked != DateTime.now()) {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      }
    },
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),
  );
}

Widget buildDropdownField(String label, List<dynamic> items, void Function(String?)? onChanged, {required String initialValue}) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      constraints: BoxConstraints(maxWidth: 800),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    ),
    value: items.contains(initialValue) ? initialValue : items.first,
    items: items.map((item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList(),
    onChanged: onChanged,
  );
}

Widget buildTextField(String label, TextEditingController controller, bool read) {
  controller.addListener(() {
    final text = controller.text.toUpperCase();
    if (controller.text != text) {
      controller.value = controller.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  });
  return SizedBox(
    width: 600,
    child: TextFormField(
      controller: controller,
      readOnly: read,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    ),
  );
}

Widget buildEmailField(String label, TextEditingController controller, bool read) {
  controller.addListener(() {
    final text = controller.text.toLowerCase();
    if (controller.text != text) {
      controller.value = controller.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  });
  return SizedBox(
    width: 600,
    child: TextFormField(
      controller: controller,
      readOnly: read,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    ),
  );
}

Widget buildNumberField(String label, TextEditingController controller, bool read) {
  return SizedBox(
    width: 600,
    child: TextFormField(
      controller: controller,
      readOnly: read,
      keyboardType: TextInputType.number, // Set keyboard type to number
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly // Allow only digits
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    ),
  );
}

Widget buildButton(String label, Color color, void Function()? onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
    ),
    child: Text(label, style: TextStyle(color: Colors.white),),
  );
}

class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  PasswordField({required this.label, required this.controller});

  @override
  // ignore: library_private_types_in_public_api
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: _toggleVisibility,
          ),
        ),
      ),
    );
  }
}