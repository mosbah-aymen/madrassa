import 'package:flutter/material.dart';
import 'package:madrassa/constants/colors.dart';

Widget buildTextFormField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
    {
      bool readOnly=false,
      bool isRequired=false,
    }
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      readOnly: readOnly,
      controller: controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        label: Text(label),
        counter:isRequired? const Text("obligatoire",style: TextStyle(fontSize: 10,color: Colors.red),):null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      keyboardType: keyboardType,
      cursorColor: primaryColor,
      validator: (value) {
        if ((value == null || value.isEmpty ) && isRequired) {
          return 'Ce champ est requis';
        }
        return null;
      },
    ),
  );
}