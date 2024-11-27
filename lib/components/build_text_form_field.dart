import 'package:flutter/material.dart';
import 'package:madrassa/constants/colors.dart';

Widget buildTextFormField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
    {
      bool readOnly=false,
      bool isRequired=false,
      Color? fillColor,
    }
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: TextFormField(
      readOnly: readOnly,
      enabled: !readOnly,
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        label: Text(label,style: const TextStyle(fontSize: 15)),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor)
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: secondaryColor)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: secondaryColor)
        ),
        fillColor: fillColor,
        filled: fillColor!=null
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